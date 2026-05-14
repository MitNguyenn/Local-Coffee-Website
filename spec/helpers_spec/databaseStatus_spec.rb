require 'spec_helper'
require 'fileutils'

RSpec.describe DatabaseStatus do
  # Include the module directly under test to match internal helper execution conventions
  include described_class
  
  # Resolve the directory target matching the module's relative structural resolution logic
  let(:test_backup_dir) { File.expand_path('../../helpers/../db/backups', __dir__) }

  before(:each) do
    # Completely clear out the target layout to isolate each evaluation scenario run
    FileUtils.rm_rf(test_backup_dir)
  end

  after(:each) do
    # Guarantee no residual temporary disk artifacts leak onto the workspace
    FileUtils.rm_rf(test_backup_dir)
  end

  describe '#list_available_backups' do
    context 'when evaluating filesystem structures directly' do
      it 'returns an empty array gracefully if the backup directory missing' do
        result = list_available_backups
        expect(result).to eq([])
      end

      it 'returns an empty array if the backup folder exists but contains no files' do
        FileUtils.mkdir_p(test_backup_dir)
        result = list_available_backups
        expect(result).to eq([])
      end

      it 'filters out alternative file extensions and captures only database snapshots' do
        FileUtils.mkdir_p(test_backup_dir)
        File.write(File.join(test_backup_dir, 'valid_state.sqlite3'), 'dummy metadata structural bytes')
        File.write(File.join(test_backup_dir, 'server_error_log.txt'), 'text stream content data info')

        result = list_available_backups
        expect(result.size).to eq(1)
        expect(result.first[:filename]).to eq('valid_state.sqlite3')
      end

      it 'maps data properties accurately converting raw footprints to Kilobyte measurements' do
        FileUtils.mkdir_p(test_backup_dir)
        target_file = File.join(test_backup_dir, 'snapshot_metrics.sqlite3')
        
        # Write exactly 4096 bytes to verify precision (4096 bytes / 1024 = 4.0 KB)
        File.write(target_file, 'x' * 4096)
        
        fixed_time = Time.new(2026, 5, 14, 12, 30, 0)
        File.utime(fixed_time, fixed_time, target_file)

        result = list_available_backups
        expect(result.size).to eq(1)
        expect(result.first).to eq({
          filename: 'snapshot_metrics.sqlite3',
          created_at: '2026-05-14 12:30:00',
          size_kb: 4.0
        })
      end

      it 'sorts returned snapshot items in clean reverse-chronological order' do
        FileUtils.mkdir_p(test_backup_dir)
        
        old_snap = File.join(test_backup_dir, 'backup_old.sqlite3')
        mid_snap = File.join(test_backup_dir, 'backup_mid.sqlite3')
        new_snap = File.join(test_backup_dir, 'backup_new.sqlite3')

        File.write(old_snap, 'data')
        File.write(mid_snap, 'data')
        File.write(new_snap, 'data')

        # Artificially shift modification times to test configuration integrity
        anchor_time = Time.now
        File.utime(anchor_time - 60, anchor_time - 60, old_snap)
        File.utime(anchor_time - 30, anchor_time - 30, mid_snap)
        File.utime(anchor_time, anchor_time, new_snap)

        result = list_available_backups
        
        expect(result.size).to eq(3)
        # Verify the array sequence (newest index registers first)
        expect(result[0][:filename]).to eq('backup_new.sqlite3')
        expect(result[1][:filename]).to eq('backup_mid.sqlite3')
        expect(result[2][:filename]).to eq('backup_old.sqlite3')
      end
    end
  end
end