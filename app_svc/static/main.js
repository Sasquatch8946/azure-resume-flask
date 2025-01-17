window.addEventListener('DOMContentLoaded', (event) => {
    getCounter();
});

async function getCounter() {
    try {
        const res = await fetch("/read_db");
        if (!res.ok) {
            throw new Error(`Response status: ${res.status}`);
        }
        const counter = await res.json();
        const count = counter['count'];
        const counterElement = document.getElementById("counter");
        counterElement.innerText = count;
    } catch (error) {
        console.error(error.message);
    }
}
