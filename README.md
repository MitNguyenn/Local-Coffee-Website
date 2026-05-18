# Badly Brewed Coffee — Team 35

A web-based coffee shop management system built with Sinatra and Ruby, supporting customer, barista, manager, and admin roles.

## Installation

### 1. Clone the repository

```bash
git clone git@git.shefcompsci.org.uk:com1001-2025-26/team35/project.gits
cd project
```

### 2. Install dependencies

```bash
bundle install
```

### 3. Initialise and seed the database

```bash
bash ./build_scripts/build_database.sh
```
OR
```ruby
ruby db/DB__init.rb
```

---

## Running and Visiting the Website
In Codio:
```bash
sinatra
```

Then click on the link seen in the terminal window

OR 
```bash
ruby app.rb
```
and visit the link 
```bash
127.0.0.1:4567
```
---

## Running the Tests

```bash
rspec
```

To run a specific test file:

```bash
rspec PATH_TO_TEST
```
Example:
```bash
rspec spec/acceptance/user_creates_account_spec.rb
```
---

## Predefined Accounts

Use these accounts to inspect the system. Each password matches the username.

| Username       | Password       | Role     |
|----------------|----------------|----------|
| testcust       | testcust       | Customer |
| testbarista    | testbarista    | Barista  |
| testmanager    | testmanager    | Manager  |
| testadmin      | testadmin      | Admin    |

---
