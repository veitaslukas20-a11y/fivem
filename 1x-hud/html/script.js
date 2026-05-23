document.addEventListener('DOMContentLoaded', () => {

    function updateHudScale() {
        const baseW = 1920;
        const baseH = 1080;
        const sx = window.innerWidth / baseW;
        const sy = window.innerHeight / baseH;
        const scale = Math.min(sx, sy);
        document.documentElement.style.setProperty('--hud-scale', scale);
    }
    updateHudScale();
    window.addEventListener('resize', updateHudScale);

    function setProgress(selector, value) {
        const circle = document.querySelector(selector);
        if (!circle) return;
        const r = circle.r.baseVal.value;
        const c = 2 * Math.PI * r;
        const pct = Math.max(0, Math.min(100, value));
        circle.style.strokeDasharray = `${c} ${c}`;
        circle.style.strokeDashoffset = c - (pct / 100) * c;
    }

    function updateSpeedometer(speed, show) {
        const container = document.querySelector('.speed-container');
        const el = document.getElementById('speed');
        if (!container || !el) return;
        container.style.display = show ? 'flex' : 'none';

        const s = Math.max(0, Math.floor(speed)).toString().padStart(3, '0');
        const d = s.split('').map(x => x || '0'); // ensure no undefined digits

        if (speed < 10)
            el.innerHTML = `<span class="grey-digit">${d[0]}</span><span class="grey-digit">${d[1]}</span><span class="white-digit">${d[2]}</span>`;
        else if (speed < 100)
            el.innerHTML = `<span class="grey-digit">${d[0]}</span><span class="white-digit">${d[1]}</span><span class="white-digit">${d[2]}</span>`;
        else
            el.innerHTML = `<span class="white-digit">${d[0]}</span><span class="white-digit">${d[1]}</span><span class="white-digit">${d[2]}</span>`;
    }

    function setIndicator(id, active) {
        const el = document.getElementById(id);
        if (!el) return;
        el.classList.toggle('active', active);
    }

    function setHeadlightIndicator(state) {
        const el = document.getElementById('ind-headlight');
        if (!el) return;
        const dot = el.querySelector('.indicator-dot');
        if (!dot) return;

        dot.style.backgroundColor = 'rgba(255,255,255,0.12)';
        dot.style.transform = 'scale(1)';

        if (state === 'low' || state === 'high') {
            dot.style.backgroundColor = '#acd15e';
            dot.style.transform = 'scale(1.05)';
        }
    }

    function updateVehicleHud(data) {
        const hud = document.getElementById('vehicle-hud');
        if (!hud) return;

        if (!data || !data.inVehicle) {
            hud.style.display = 'none';
            return;
        }

        hud.style.display = 'flex';

        const fuel = Math.max(0, Math.min(100, data.fuel || 0));
        const fuelBar = document.getElementById('fuel-bar');
        const fuelText = document.getElementById('fuel-text');
        if (fuelBar) fuelBar.style.width = fuel + '%';
        if (fuelText) fuelText.textContent = Math.round(fuel) + ' L';

        const engine = Math.max(0, Math.min(100, data.engine || 0));
        const engineBar = document.getElementById('engine-bar');
        const engineText = document.getElementById('engine-text');
        if (engineBar) engineBar.style.width = engine + '%';
        if (engineText) engineText.textContent = Math.round(engine) + '%';

        const kmWhole = Math.floor(Number(data.mileage || 0));
        const mileageEl = document.getElementById('mileage');
        if (mileageEl) mileageEl.textContent = kmWhole.toString().padStart(7, '0');

        setIndicator('ind-locked', !!data.locked);
        setIndicator('ind-seatbelt', !!data.seatbelt);
        setIndicator('ind-engine', engine > 0);
        setHeadlightIndicator(data.lights || 'off');
    }

    function updateTextWithTransition(element, newText) {
        if (!element || element.textContent === newText) return;

        element.classList.add('fade-out');
        setTimeout(() => {
            element.textContent = newText;
            element.classList.remove('fade-out');
            element.classList.add('fadeUp');
            setTimeout(() => element.classList.remove('fadeUp'), 400);
        }, 150);
    }

    function updateTime() {
        const d = new Date();
        const timeEl = document.getElementById('time-indicator');
        const dateEl = document.getElementById('date-indicator');

        const newTime = d.getHours().toString().padStart(2, '0') + ':' +
                        d.getMinutes().toString().padStart(2, '0');
        const newDate = `${d.getFullYear()}.${(d.getMonth() + 1).toString().padStart(2,'0')}.${d.getDate().toString().padStart(2,'0')}`;

        updateTextWithTransition(timeEl, newTime);
        updateTextWithTransition(dateEl, newDate);
    }

    setInterval(updateTime, 1000);
    updateTime();

    let minimapAnchor = { left_x: null, right_x: null, y: null, height: null };

    function formatIcon(icon) {
        if (!icon) return "fas fa-car";
        if (!icon.includes("fa-")) return "fas fa-" + icon;
        return icon.replace("fa-solid", "fas");
    }

    function appendTransform(element, value) {
        const current = element.style.transform || "";
        element.style.transform = current + " " + value;
    }

    function showNotify(title, message, icon, duration = 5000) {
        icon = formatIcon(icon);

        const notify = document.createElement("div");
        notify.className = "notify";
        notify.innerHTML = `
            <div class="text">
                <div class="title">
                    <div class="icon"><i class="${icon}"></i></div>
                    ${title}
                </div>
                <div class="message">${message}</div>
            </div>
        `;

        const container = document.getElementById("minimap-notifies");
        if (!container) return;

        if (minimapAnchor.left_x !== null && minimapAnchor.right_x !== null && minimapAnchor.y !== null) {
            const bottomPercent = 100 - minimapAnchor.y + 4;
            container.style.left = '1.5%';
            container.style.bottom = `${bottomPercent}%`;
            container.style.transform = 'translateX(0)';
        } else {
            container.style.left = '50%';
            container.style.bottom = '22%';
            container.style.transform = 'translateX(-50%)';
        }

        container.appendChild(notify);

        const notifySound = document.getElementById('notify-sound');
        if (notifySound) {
            notifySound.pause();
            notifySound.currentTime = 0;
            notifySound.volume = 0.1;
            notifySound.play().catch(e => console.log("Audio play failed:", e));
        }

        setTimeout(() => {
            notify.style.opacity = "0";
            appendTransform(notify, "translateY(-20px)");
            setTimeout(() => notify.remove(), 400);
        }, duration);
    }

    const announcementQueue = [];
    let isShowingAnnouncement = false;

    function showAnnouncement(title, message, icon, duration = 5000) {
        announcementQueue.push({ title, message, icon, duration });
        processAnnouncementQueue();
    }

    function processAnnouncementQueue() {
        if (isShowingAnnouncement || announcementQueue.length === 0) return;
        isShowingAnnouncement = true;

        const { title, message, icon, duration } = announcementQueue.shift();
        const notify = document.createElement("div");
        notify.className = "notify";
        notify.innerHTML = `
            <div class="icon"><i class="${formatIcon(icon)}"></i></div>
            <div class="text">
                <div class="title">${title}</div>
                <div class="message">${message}</div>
            </div>
        `;

        const container = document.getElementById("top-notifies");
        if (!container) {
            isShowingAnnouncement = false;
            return;
        }
        container.appendChild(notify);

        const notifySound = document.getElementById('notify-sound');
        if (notifySound) {
            notifySound.pause();
            notifySound.currentTime = 0;
            notifySound.volume = 0.1;
            notifySound.play().catch(() => {});
        }

        setTimeout(() => {
            notify.style.opacity = "0";
            appendTransform(notify, "translateY(-20px)");
            setTimeout(() => {
                notify.remove();
                isShowingAnnouncement = false;
                processAnnouncementQueue();
            }, 400);
        }, duration);
    }

    window.addEventListener('message', (event) => {
        const d = event.data;
        if (!d) return;

        // Fix optional chaining on assignment
        const hudEl = document.querySelector('.hud');
        if (hudEl && d.showHud !== undefined) {
            hudEl.style.display = d.showHud ? 'flex' : 'none';
        }

        if (d.health !== undefined) setProgress('#health-progress .progress-circle', d.health);
        if (d.armor !== undefined) setProgress('#armor-progress .progress-circle', d.armor);
        if (d.hunger !== undefined) setProgress('#hunger-progress .progress-circle', d.hunger);
        if (d.thirst !== undefined) setProgress('#thirst-progress .progress-circle', d.thirst);

        if (d.playerId !== undefined) {
            const playerIdEl = document.getElementById('player-id-value');
            if (playerIdEl) playerIdEl.textContent = d.playerId;
        }

        if (d.pcount !== undefined) {
            const pcountEl = document.getElementById('player-count');
            if (pcountEl) pcountEl.textContent = d.pcount;
        }

        if (d.speed !== undefined || d.showSpeed !== undefined) updateSpeedometer(d.speed || 0, d.showSpeed || false);

        if (d.vehicleHud !== undefined) updateVehicleHud(d.vehicleHud);

        if (d.location !== undefined) {
            const locationText = document.getElementById('location-text');
            const newLocation = d.location && d.location.length > 0 ? d.location : 'Unknown';
            updateTextWithTransition(locationText, newLocation);
        }

        const safezoneEl = document.getElementById('safezone-indicator');
        if (safezoneEl && d.safeZone !== undefined) {
            safezoneEl.style.display = d.safeZone ? 'flex' : 'none';
        }

        if (d.action === 'minimapAnchor') {
            minimapAnchor = { left_x: d.left_x, right_x: d.right_x, y: d.y, height: d.height };
            const hud = document.getElementById('hud');
            if (hud) {
                hud.style.position = 'fixed';
                hud.style.left = (d.right_x + 0.5) + '%';
                hud.style.bottom = (100 - d.y - (d.height - 1.4)) + '%';
            }
        }

        if (d.action === "toggleHud") {
            const root = document.querySelector('.hud-root');
            if (root) {
                root.style.display = d.visible ? 'block' : 'none';
            }
        }

        if (d.action === "showNotify") showNotify(d.title, d.message, d.icon, d.duration);
        if (d.action === "showAnnouncement") showAnnouncement(d.title, d.message, d.icon, d.duration);
    });

});