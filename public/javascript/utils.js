console.log("utils.js loaded");

function eventHandlerBeanPage() {
	const container = document.getElementById('item-container');

	container.addEventListener('click', (event) => {
		const target = event.target;
		const card = target.closest('.product-card');

		if (!card) return; 

		const beanId = card.dataset.beanId;

		if (target.classList.contains('add-to-basket-button')) {
			addBeanToBasket(beanId);
			return;
		}

		if (target.classList.contains('buy-button')) {
			buyBeanNow(beanId());
			return;
		}

		if (card) {
		  window.location.href = `/product/?type=bean&id=${beanId}`;
		}
	});
}

function eventHandlerDrinkPage() {
  const container = document.getElementById('item-container');

  container.addEventListener('click', (event) => {
    const target = event.target;
    const card = target.closest('.product-card');
    
    if (!card) return;

    const drinkId = card.dataset.drinkId;

    if (target.classList.contains('add-to-basket-button')) {
		addDrinkToBasket(drinkId)
    	return;
    }

    if (target.classList.contains('buy-button')) {
		buyDrinkNow(drinkId);
		return;
    }

    if (card) {
    	window.location.href = `/drink-details/${drinkId}`;
    }
  });
}

function buyBeanNow(beanId) {
  fetch('/add-to-basket', {
	method: 'POST',
	headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
	body: `id=${beanId}&type=bean`
  })
  .then(() => {
	window.location.href = '/checkout';
  });
}

function buyDrinkNow(drinkId, size = 'regular') {
  fetch('/add-to-basket', {
	method: 'POST',
	headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
	body: `id=${drinkId}&type=drink&size=${size}`
  })
  .then(() => {
	window.location.href = '/checkout';
  });
}

function addBeanToBasket(beanId) {
  fetch('/add-to-basket', {
	method: 'POST',
	headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
	body: `id=${beanId}&type=bean`
  })
  .then(response => response.json())
  .then(data => {
	const cartCount = document.getElementById('basket-count');
	if (cartCount) cartCount.textContent = data.count;
	
	target.textContent = "Added! ✅";
	setTimeout(() => { target.textContent = "Remove from basket"; }, 1000);
  });
}

function addDrinkToBasket(drinkId, size = 'regular') {
  fetch('/add-to-basket', {
	method: 'POST',
	headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
	body: `id=${drinkId}&type=drink&size=${size}`
  })
  .then(response => response.json())
  .then(data => {
	const cartCount = document.getElementById('basket-count');
	if (cartCount) cartCount.textContent = data.count;
	
	target.textContent = "Added! ✅";
	setTimeout(() => { target.textContent = "Remove from basket"; }, 1000);
  });
}

window.eventHandlerBeanPage = eventHandlerBeanPage;
window.eventHandlerDrinkPage = eventHandlerDrinkPage;
