function validateInput(input) {
    input.value = input.value.replace(/[^A-Za-z]/g, '');
}

function formatName(name) {
    return name.charAt(0).toUpperCase() + name.slice(1).toLowerCase();
}

function closeUI() {
    document.querySelector("body").style.display = "none";

    fetch("https://vision_namechange/closeUI", {
        method: "POST",
    }).then(() => {
        return fetch("https://vision_namechange/hideAll", {
            method: "POST",
        });
    })
}

function changeName() {
    const firstnameInput = document.querySelector("#firstname");
    const lastnameInput = document.querySelector("#lastname");

    if (firstnameInput.value.length < 3 || lastnameInput.value.length < 3) {
        console.log("First name or last name too short");
        closeUI();
        return;
    }

    const firstname = formatName(firstnameInput.value);
    const lastname = formatName(lastnameInput.value);

    fetch("https://vision_namechange/changeName", {
        method: "POST",
        body: JSON.stringify({
            firstname: firstname,
            lastname: lastname,
        }),
        headers: {
            'Content-Type': 'application/json'
        }
    })
    .then(() => {
        closeUI();
    })
}

window.addEventListener("message", function (event) {
    if (event.data.action === "openUI") {
        openUI();
    }
    if (event.data.action === "closeUI") {
        closeUI();
    }
});

function openUI() {
    document.querySelector("body").style.display = "block";
}
