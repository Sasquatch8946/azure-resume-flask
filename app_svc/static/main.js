window.addEventListener('DOMContentLoaded', (event) => {
    getCounter();
});

async function getCounter() {
    const res = await fetch("/read_db");
    const counter = await res.json();
    const count = counter['count'];
    const counterElement = document.getElementById("counter");
    counterElement.innerText = count;
}
