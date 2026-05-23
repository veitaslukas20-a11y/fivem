(function(){
  const $ = (q)=>document.querySelector(q);
  const root = $('#root');
  // UI visada paslėptas iki Lua signalo
  root.style.display = 'none';

  const tab95 = $('#tab95');
  const tab98 = $('#tab98');
  const range = $('#rangeLiters');
  const txtLiters = $('#txtLiters');
  const txtPricePer = $('#txtPricePer');
  const txtStock = $('#txtStock');
  const txtTotal = $('#txtTotal');
  const btnFill = $('#btnFill');
  const btnClose = $('#btnClose');
  const extraList = $('#extraList');

  const state = {
    visible: false,
    fuelType: 'regular',
    priceRegular: 45.0,
    pricePremium: 65.0,
    stockRegular: 0,
    stockPremium: 0,
    liters: 0,
    payment: 'cash'
  };

  function euros(n){ return (Math.round(n*100)/100).toLocaleString('lt-LT') + ' €'; }
  function liters(n){ return (Math.round(n*100)/100).toFixed(2) + ' L'; }
  function render(){
    if(!state.visible){
      root.style.display = 'none';
      return;
    }
    root.style.display = 'flex';
    const price = state.fuelType === 'premium' ? state.pricePremium : state.priceRegular;
    const stock = state.fuelType === 'premium' ? state.stockPremium : state.stockRegular;
    txtPricePer.textContent = price.toFixed(2);
    txtStock.textContent = Math.max(0, Math.round(stock));
    txtLiters.textContent = liters(state.liters);
    txtTotal.textContent = euros(state.liters * price);
    tab95.classList.toggle('tab--active', state.fuelType==='regular');
    tab98.classList.toggle('tab--active', state.fuelType==='premium');
  }

  tab95.addEventListener('click', ()=>{ state.fuelType='regular'; render(); });
  tab98.addEventListener('click', ()=>{ state.fuelType='premium'; render(); });
  range.addEventListener('input', ()=>{ state.liters = parseFloat(range.value)||0; render(); });
  document.querySelectorAll('input[name="pay"]').forEach(el=>{
    el.addEventListener('change', ()=>{ state.payment = el.value; });
  });

  btnFill.addEventListener('click', ()=>{
    fetch(`https://${GetParentResourceName()}/processFuelPayment`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify({ fuelType: state.fuelType==='premium'?'premium':'regular', liters: state.liters, paymentMethod: state.payment })
    });
  });

  function closeUI(){
    state.visible=false; render();
    fetch(`https://${GetParentResourceName()}/closeUI`, { method:'POST', body:'{}' });
  }
  btnClose.addEventListener('click', closeUI);
  document.addEventListener('keydown', (ev)=>{ if(ev.key==='Escape' && state.visible) closeUI(); });

  // Extras (su ox_inventory paveiksliukais)
  const extras = [
    { key:'kanistras', title:'Kuro Bakelis', price:14300, image:'https://cfx-nui-ox_inventory/web/images/kanistras.png' },
    { key:'fixkit', title:'Taisymo rinkinys', price:16500, image:'https://cfx-nui-ox_inventory/web/images/fixkit.png' }
  ];
  function renderExtras(){
    extraList.innerHTML = '';
    extras.forEach(x=>{
      const el = document.createElement('div');
      el.className='card';
      el.innerHTML = `<div class="card__left">
          <img src="${x.image}" class="card__icon" alt="${x.title}">
          <div class="card__title">${x.title}</div>
        </div>
        <div class="card__right"><div class="card__price">${euros(x.price)}</div>
        <button class="card__buy">PIRKTI</button></div>`;
      el.querySelector('.card__buy').addEventListener('click', ()=>{
        fetch(`https://${GetParentResourceName()}/buyItem`, {
          method:'POST', headers:{'Content-Type':'application/json'},
          body: JSON.stringify({ item:x.key, paymentMethod: state.payment })
        });
      });
      extraList.appendChild(el);
    });
  }
  renderExtras();

  // NUI messages
  window.addEventListener('message', (e)=>{
    const d = e.data || {};
    if(d.action === 'setVisible'){
      state.visible = !!(d.data && d.data.visible);
      render();
    } else if(d.action === 'setFuelData'){
      const dt = d.data || {};
      state.priceRegular = dt.regularPrice ?? state.priceRegular;
      state.pricePremium = dt.premiumPrice ?? state.pricePremium;
      state.stockRegular = dt.stockRegular ?? state.stockRegular;
      state.stockPremium = dt.stockPremium ?? state.stockPremium;
      render();
    }
  });

  // niekada nerenderinam automatiškai
})();
