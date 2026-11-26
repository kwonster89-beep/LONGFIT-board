(async()=>{
if(location.host!=='trade.egojinsvc.com'){alert('무역허브(trade.egojinsvc.com) 페이지에서 눌러주세요.');return;}
const w=window.open('about:blank','_blank');
const say=(t,c)=>{try{w.document.body.innerHTML='<div style="font:16px sans-serif;padding:40px;color:'+(c||'#2f5597')+'">'+t+'</div>';}catch(e){}};
say('키룬 PI 갱신: 상품 목록 읽는 중...');
try{
const d=await (await fetch('https://raw.githubusercontent.com/kwonster89-beep/LONGFIT-board/main/docs/data.json?t='+Date.now(),{cache:'no-store'})).json();
const C=new Set(d.items.map(i=>String(i.code)));
let B='';try{B=(await (await fetch('https://raw.githubusercontent.com/kwonster89-beep/LONGFIT-board/main/docs/stock.json?t='+Date.now(),{cache:'no-store'})).json()).base_date||'';}catch(e){}
say('키룬 PI 갱신: 무역허브 발주 데이터 읽는 중... (10~30초)');
const r=await fetch('/api/trade-purchase-orders',{credentials:'include'});
const t=await r.json();
const L=[];
for(const p of t.items||[]){if(p.isCancelled||p.isDummy)continue;
if(p.stage==='inbound'||p.progressTone==='done')continue;
const E=(p.logistics&&p.logistics.etd)||'';if(B&&E&&E<B)continue;
for(const l of p.lines||[]){if(!C.has(String(l.ezadminId)))continue;
L.push({pi:p.piNumber||'',etd:(p.logistics&&p.logistics.etd)||'',stage:p.stageLabel||'',code:String(l.ezadminId),name:l.productName||'',units:Number(l.actualShippedQuantity??l.currentQuantity??l.quantity??0)||0});}}
if(!L.length)throw new Error('남은 PI를 하나도 찾지 못했어요');
L.sort((a,b)=>(b.etd||'9999').localeCompare(a.etd||'9999')||a.pi.localeCompare(b.pi));
const n=new Date(Date.now()+9*36e5).toISOString().slice(0,16).replace('T',' ')+' KST';
const b=btoa(unescape(encodeURIComponent(JSON.stringify({synced_at:n,source:'무역허브 발주 관리',lines:L}))));
w.location.href='https://kwonster89-beep.github.io/LONGFIT-board/?v='+Date.now()+'#sync='+encodeURIComponent(b);
}catch(e){say('키룬 PI 갱신 실패: '+e.message+'<br>무역허브 로그인 상태를 확인해 주세요.','#c62828');}
})();
