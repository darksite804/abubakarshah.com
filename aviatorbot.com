<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Aviator Signal Dashboard</title>
<style>
*{box-sizing:border-box}body{margin:0;font-family:Arial,sans-serif;background:#080b14;color:#fff;min-height:100vh}
.wrap{max-width:1050px;margin:auto;padding:28px 16px}
header{text-align:center;padding:25px 0 18px}h1{font-size:34px;margin:0 0 8px}header p{color:#aab2c5;margin:0}
.grid{display:grid;grid-template-columns:1.3fr 1fr;gap:18px}.card{background:#111625;border:1px solid #273047;border-radius:20px;padding:22px;box-shadow:0 12px 35px #0005}
.signal{text-align:center;padding:32px 15px}.label{color:#9da8bd;text-transform:uppercase;letter-spacing:2px;font-size:12px}
.signal h2{font-size:48px;margin:10px 0}.green{color:#31e981}.yellow{color:#ffd34d}.red{color:#ff5964}
.stats{display:grid;grid-template-columns:repeat(3,1fr);gap:10px;margin-top:20px}.stat{background:#0b101c;border-radius:14px;padding:15px;text-align:center}.stat b{font-size:21px;display:block;margin-top:5px}
input,button{width:100%;padding:13px;border-radius:12px;border:1px solid #303a53;background:#0b101c;color:#fff;font-size:15px}
button{cursor:pointer;background:#6b43ff;border:0;font-weight:bold;margin-top:10px}button:hover{filter:brightness(1.15)}
.rounds{display:flex;flex-wrap:wrap;gap:8px;margin-top:12px}.pill{padding:8px 11px;border-radius:10px;background:#1a2234}.small{font-size:12px;color:#8995ab;margin-top:12px;line-height:1.5}
@media(max-width:700px){.grid{grid-template-columns:1fr}h1{font-size:28px}}
</style>
</head>
<body>
<div class="wrap">
<header><h1>🚀 AVIATOR SIGNAL BOT</h1><p>Rule-based demo signal dashboard</p></header>

<div class="grid">
<section class="card signal">
<div class="label">Current Signal</div>
<h2 id="signal" class="yellow">WAIT</h2>
<div id="reason">Enter recent multipliers to generate a demo signal.</div>
<div class="stats">
<div class="stat"><span>Suggested</span><b id="cashout">—</b></div>
<div class="stat"><span>Score</span><b id="score">—</b></div>
<div class="stat"><span>Rounds</span><b id="count">0</b></div>
</div>
</section>

<section class="card">
<h3>Recent Multipliers</h3>
<input id="roundInput" placeholder="Example: 1.12, 2.10, 1.45, 3.20">
<button onclick="analyze()">GENERATE SIGNAL</button>
<button onclick="randomDemo()">LOAD DEMO DATA</button>
<div class="small">This is a statistical demo only. It cannot know or guarantee the next Aviator crash point.</div>
</section>
</div>

<section class="card" style="margin-top:18px">
<h3>Round History</h3><div id="rounds" class="rounds"></div>
</section>
</div>

<script>
function analyze(){
 const raw=document.getElementById('roundInput').value;
 const a=raw.split(',').map(x=>parseFloat(x.trim())).filter(x=>Number.isFinite(x)&&x>=1);
 if(!a.length){setSignal('WAIT','Enter valid multipliers.','—','—');return}
 const last=a.slice(-10), avg=last.reduce((x,y)=>x+y,0)/last.length;
 const low=last.filter(x=>x<1.5).length, high=last.filter(x=>x>=2).length;
 let score=50;
 if(low>=3) score+=10;
 if(high>=3) score-=8;
 if(avg>2) score-=8;
 if(avg<1.6) score+=6;
 let s='WAIT', cls='yellow', cash='1.50x–2.00x';
 if(score>=62){s='BET',cls='green'} else if(score<=40){s='SKIP',cls='red';cash='—'}
 let reason=`Last ${last.length} rounds average ${avg.toFixed(2)}x.`;
 setSignal(s,reason,cash,score+'%');
 render(a);
}
function setSignal(s,r,c,sc){
 const el=document.getElementById('signal');el.textContent=s;el.className=s==='BET'?'green':s==='SKIP'?'red':'yellow';
 document.getElementById('reason').textContent=r;document.getElementById('cashout').textContent=c;document.getElementById('score').textContent=sc;
}
function render(a){document.getElementById('count').textContent=a.length;document.getElementById('rounds').innerHTML=a.slice(-30).reverse().map(x=>`<span class="pill">${x.toFixed(2)}x</span>`).join('')}
function randomDemo(){
 let a=Array.from({length:15},()=>Math.max(1,+(1+Math.random()*3.5).toFixed(2)));
 document.getElementById('roundInput').value=a.join(', ');analyze();
}
</script>
</body></html>
