/**
 * MODULE BASES DE DONNÉES — 3e ANNÉE SCIENCES DE L'INFORMATIQUE (STI)
 * Navigation phase par phase & Espace Enseignant Sécurisé
 */
document.addEventListener("DOMContentLoaded", () => {
  // ------------------------------------------------------------------------
  // 1. ESPACE ENSEIGNANT SÉCURISÉ (Authentification, Corrigés, Découpage)
  // ------------------------------------------------------------------------
  const TEACHER_AUTH_KEY = "bd_3sti_teacher_authenticated";
  const TEACHER_PASSWORDS = ["prof", "professeur", "sti", "sti2026"];

  const btnSolutions = document.getElementById("btnSolutions");
  const btnPlan = document.getElementById("btnPlan");
  const btnPrint = document.getElementById("btnPrint");
  const toolbarActions = document.querySelector(".toolbar-actions");

  function isTeacherAuthenticated() {
    return localStorage.getItem(TEACHER_AUTH_KEY) === "1";
  }

  function setTeacherAuthenticated(state, notify = false) {
    if (state) {
      localStorage.setItem(TEACHER_AUTH_KEY, "1");
      document.body.classList.add("teacher-authenticated");
    } else {
      localStorage.removeItem(TEACHER_AUTH_KEY);
      document.body.classList.remove("teacher-authenticated");
      document.body.classList.remove("show-solutions");
      document.body.classList.remove("show-plan");
      if (btnSolutions) {
        btnSolutions.classList.remove("btn-active");
        btnSolutions.textContent = "Afficher les corrigés";
      }
      if (btnPlan) {
        btnPlan.classList.remove("btn-active");
        btnPlan.textContent = "Afficher le découpage horaire";
      }
    }
    updateTeacherUI(state);
    if (notify) {
      if (state) {
        alert("🎓 Mode Enseignant ACTIVÉ.\nLes corrigés et le découpage horaire sont déverrouillés sur l'ensemble du module.");
      } else {
        alert("🔒 Mode Enseignant DÉSACTIVÉ.\nRetour au mode élève (les corrigés sont entièrement masqués).");
      }
    }
  }

  function promptTeacherPassword() {
    const entered = window.prompt("Espace Enseignant STI — Saisir le code d'accès :");
    if (entered === null) return;
    const clean = entered.trim().toLowerCase();
    if (TEACHER_PASSWORDS.includes(clean)) {
      setTeacherAuthenticated(true, true);
    } else {
      alert("❌ Code d'accès incorrect. Accès réservé à l'enseignant.");
    }
  }

  function updateTeacherUI(isAuth) {
    // Gestion du bouton ou badge dans la toolbar
    const existingBadge = document.getElementById("badgeTeacher");
    const existingLockBtn = document.getElementById("btnTeacherAuth");
    const existingLogoutBtn = document.getElementById("btnTeacherLogout");

    if (existingBadge) existingBadge.remove();
    if (existingLockBtn) existingLockBtn.remove();
    if (existingLogoutBtn) existingLogoutBtn.remove();

    if (toolbarActions) {
      if (isAuth) {
        // Badge enseignant
        const badge = document.createElement("span");
        badge.id = "badgeTeacher";
        badge.className = "badge-teacher";
        badge.innerHTML = "🎓 Enseignant";
        toolbarActions.insertBefore(badge, toolbarActions.firstChild);

        // Bouton Quitter
        const btnLogout = document.createElement("button");
        btnLogout.id = "btnTeacherLogout";
        btnLogout.type = "button";
        btnLogout.className = "btn btn-teacher-logout";
        btnLogout.title = "Verrouiller et revenir au mode élève";
        btnLogout.textContent = "🔒 Quitter";
        btnLogout.addEventListener("click", () => {
          setTeacherAuthenticated(false, true);
        });
        toolbarActions.appendChild(btnLogout);
      } else {
        // Cadenas discret
        const btnLock = document.createElement("button");
        btnLock.id = "btnTeacherAuth";
        btnLock.type = "button";
        btnLock.className = "btn btn-teacher-lock";
        btnLock.title = "Accès Enseignant (Raccourci : Alt + P)";
        btnLock.textContent = "🔒";
        btnLock.addEventListener("click", promptTeacherPassword);
        toolbarActions.appendChild(btnLock);
      }
    }

    // Gestion de l'éventuelle bannière sur index.html
    const indexBanner = document.getElementById("teacherBannerIndex");
    if (indexBanner) {
      indexBanner.style.display = isAuth ? "flex" : "none";
    }
  }

  // Vérifier URL param (?prof ou ?eleve / ?logout)
  const urlParams = new URLSearchParams(window.location.search);
  if (urlParams.has("eleve") || urlParams.has("logout")) {
    setTeacherAuthenticated(false);
  } else if (urlParams.has("prof") || urlParams.has("teacher") || window.location.hash === "#prof") {
    setTeacherAuthenticated(true);
  } else {
    setTeacherAuthenticated(isTeacherAuthenticated());
  }

  // Raccourci clavier secret : Alt + P ou Ctrl + Shift + P
  window.addEventListener("keydown", (e) => {
    if (e.target.tagName === "INPUT" || e.target.tagName === "TEXTAREA") return;
    if ((e.altKey && (e.key === "p" || e.key === "P")) ||
        (e.ctrlKey && e.shiftKey && (e.key === "p" || e.key === "P"))) {
      e.preventDefault();
      if (isTeacherAuthenticated()) {
        const quit = confirm("Le Mode Professeur est actif.\nSouhaitez-vous le verrouiller et revenir en mode élève ?");
        if (quit) setTeacherAuthenticated(false, true);
      } else {
        promptTeacherPassword();
      }
    }
  });

  // Liaison bouton Corrigés
  if (btnSolutions) {
    btnSolutions.addEventListener("click", () => {
      if (!isTeacherAuthenticated()) return;
      const active = document.body.classList.toggle("show-solutions");
      btnSolutions.classList.toggle("btn-active", active);
      btnSolutions.textContent = active
        ? "Masquer les corrigés"
        : "Afficher les corrigés";
    });
  }

  // Liaison bouton Découpage horaire
  if (btnPlan) {
    btnPlan.addEventListener("click", () => {
      if (!isTeacherAuthenticated()) return;
      const active = document.body.classList.toggle("show-plan");
      btnPlan.classList.toggle("btn-active", active);
      btnPlan.textContent = active
        ? "Masquer le découpage horaire"
        : "Afficher le découpage horaire";
    });
  }

  // Impression
  if (btnPrint) {
    btnPrint.addEventListener("click", () => {
      window.print();
    });
  }

  // Bouton déconnexion sur index.html
  const btnIndexLogout = document.getElementById("btnIndexLogout");
  if (btnIndexLogout) {
    btnIndexLogout.addEventListener("click", () => {
      setTeacherAuthenticated(false, true);
    });
  }
  const btnFooterTeacher = document.getElementById("btnFooterTeacher");
  if (btnFooterTeacher) {
    btnFooterTeacher.addEventListener("click", () => {
      if (isTeacherAuthenticated()) {
        setTeacherAuthenticated(false, true);
      } else {
        promptTeacherPassword();
      }
    });
  }

  // ------------------------------------------------------------------------
  // 2. EXTRACTION DES TITRES COURTS & GESTION DES ONGLETS
  // ------------------------------------------------------------------------
  function getShortTitle(fullText, badgeText, index) {
    let clean = fullText || "";
    if (badgeText) {
      clean = clean.replace(badgeText, "").trim();
    }
    clean = clean.replace(/^\d+\.\s*/, "").trim();
    const lower = clean.toLowerCase();

    if (lower.startsWith("partie")) {
      const m = clean.match(/Partie\s*\d+\s*:\s*([^(\n]+)/i);
      if (m) {
        const sub = m[1].trim().toLowerCase();
        if (sub.includes("modélisation")) return "Modélisation";
        if (sub.includes("définition") || sub.includes("ldd")) return "LDD";
        if (sub.includes("manipulation") || sub.includes("lmd")) return "LMD";
        if (sub.includes("interrogation") || sub.includes("select")) return "SELECT";
        return m[1].trim().substring(0, 16);
      }
      return `Partie ${index + 1}`;
    }

    if (lower.includes("jeu de données") || lower.includes("données de référence")) {
      return "Données";
    }

    if (lower.includes("accroche")) return "Accroche";
    if (lower.includes("situation")) return "Situation";
    if (lower.includes("prise en main")) return "Prise en main";
    if (lower.includes("expérience")) return "Expérience";
    if (lower.includes("découverte")) return "Découverte";
    if (lower.includes("préparation")) return "Préparation";
    if (lower.includes("synthèse")) return "Synthèse";
    if (lower.includes("tp guidé")) return "TP guidé";
    if (lower.includes("laboratoire")) return "Laboratoire";
    if (lower.includes("chasse") || lower.includes("atelier")) return "Atelier pièges";
    if (lower.includes("application")) return "Application";
    if (lower.includes("quiz")) return "Quiz éclair";

    const parts = clean.split(":");
    return parts[0].trim().substring(0, 15) || `Étape ${index + 1}`;
  }

  function getCompactBadge(badgeText) {
    if (!badgeText) return "";
    const m = badgeText.match(/(\d+\s*(?:min|points|pts))/i);
    if (m) {
      return m[1].replace(/points/i, "pts").replace(/\s+/, " ");
    }
    return badgeText.split("—")[0].trim().substring(0, 10);
  }

  // ------------------------------------------------------------------------
  // 3. CONSTRUCTION DU MODE PHASE PAR PHASE
  // ------------------------------------------------------------------------
  const container = document.querySelector("main.container");
  if (!container) return;

  const phases = Array.from(container.querySelectorAll("section.phase"));
  if (phases.length <= 1) return;

  const teacherPlan = container.querySelector(".teacher-plan");
  const sheetHeader = container.querySelector("header.sheet-header");

  // Conteneur global du bloc de navigation
  const navContainer = document.createElement("nav");
  navContainer.className = "phase-nav-container";
  navContainer.setAttribute("aria-label", "Progression de la séance");

  // En-tête
  const navHeader = document.createElement("div");
  navHeader.className = "phase-nav-header";

  const navTitle = document.createElement("div");
  navTitle.className = "phase-nav-title";
  navTitle.innerHTML = `<span class="phase-badge-status">Phase active</span> <span class="phase-current-label"></span>`;

  const btnAll = document.createElement("button");
  btnAll.type = "button";
  btnAll.className = "btn-view-all";
  btnAll.innerHTML = `<span>👁️ Afficher toutes les phases</span>`;

  navHeader.appendChild(navTitle);
  navHeader.appendChild(btnAll);
  navContainer.appendChild(navHeader);

  // Grille d'onglets (sans défilement horizontal)
  const tabsWrap = document.createElement("div");
  tabsWrap.className = "phase-tabs";
  // Adapter le nombre de colonnes en fonction du nombre de phases
  tabsWrap.style.gridTemplateColumns = `repeat(${Math.min(phases.length, 6)}, minmax(0, 1fr))`;

  const tabButtons = [];

  phases.forEach((phase, index) => {
    phase.id = `phase-${index + 1}`;

    const heading = phase.querySelector("h2, h3");
    const fullText = heading ? heading.innerText.trim() : `Phase ${index + 1}`;

    const badgeEl = phase.querySelector(".badge-time, .q-pts, .badge-pts");
    const badgeRaw = badgeEl ? badgeEl.innerText.trim() : "";
    const compactBadge = getCompactBadge(badgeRaw);
    const shortTitle = getShortTitle(fullText, badgeRaw, index);

    const isPartie = fullText.toLowerCase().includes("partie");
    const prefix = isPartie ? `Partie ${index + 1}` : `Phase ${index + 1}`;

    const tab = document.createElement("button");
    tab.type = "button";
    tab.className = "phase-tab" + (index === 0 ? " active" : "");
    tab.setAttribute("data-index", index);
    tab.title = fullText;

    tab.innerHTML = `
      <div class="phase-tab-top">
        <span class="phase-tab-num">${prefix}</span>
        ${compactBadge ? `<span class="phase-badge-time">${compactBadge}</span>` : ""}
      </div>
      <div class="phase-tab-title">${shortTitle}</div>
    `;

    tabsWrap.appendChild(tab);
    tabButtons.push(tab);

    // Pied de phase avec navigation Précédente / Suivante
    const footer = document.createElement("div");
    footer.className = "phase-footer";

    const prevBtn = document.createElement("button");
    prevBtn.type = "button";
    prevBtn.className = "btn-phase-nav btn-phase-prev";
    prevBtn.innerHTML = `← ${index > 0 ? (isPartie ? `Partie ${index}` : `Phase ${index}`) : "Début"}`;
    prevBtn.disabled = index === 0;

    const indicator = document.createElement("span");
    indicator.className = "phase-indicator";
    indicator.textContent = `${prefix} sur ${phases.length} : ${shortTitle}`;

    const nextBtn = document.createElement("button");
    nextBtn.type = "button";
    nextBtn.className = "btn-phase-nav btn-phase-next";
    nextBtn.innerHTML = index < phases.length - 1
      ? `${isPartie ? `Partie ${index + 2}` : `Phase ${index + 2}`} →`
      : `Fin de la séance ✔`;

    prevBtn.addEventListener("click", () => switchPhase(index - 1));
    nextBtn.addEventListener("click", () => {
      if (index < phases.length - 1) {
        switchPhase(index + 1);
      } else {
        btnAll.click();
      }
    });

    footer.appendChild(prevBtn);
    footer.appendChild(indicator);
    footer.appendChild(nextBtn);
    phase.appendChild(footer);
  });

  navContainer.appendChild(tabsWrap);

  // Positionner la barre après l'en-tête (ou teacher-plan)
  if (teacherPlan && teacherPlan.nextSibling) {
    container.insertBefore(navContainer, teacherPlan.nextSibling);
  } else if (sheetHeader && sheetHeader.nextSibling) {
    container.insertBefore(navContainer, sheetHeader.nextSibling);
  } else {
    container.insertBefore(navContainer, phases[0]);
  }

  let isSingleMode = true;
  let currentIndex = 0;

  function updateCurrentLabel() {
    const activeHeading = phases[currentIndex] ? phases[currentIndex].querySelector("h2, h3") : null;
    if (activeHeading) {
      let t = activeHeading.innerText.trim();
      const badge = phases[currentIndex].querySelector(".badge-time, .q-pts, .badge-pts");
      if (badge) t = t.replace(badge.innerText, "").trim();
      const lbl = navTitle.querySelector(".phase-current-label");
      if (lbl) lbl.textContent = t;
    }
  }

  function switchPhase(newIndex) {
    if (newIndex < 0 || newIndex >= phases.length) return;
    currentIndex = newIndex;
    isSingleMode = true;
    document.body.classList.add("mode-single-phase");
    btnAll.classList.remove("active");
    btnAll.innerHTML = `<span>👁️ Afficher toutes les phases</span>`;

    phases.forEach((p, idx) => {
      p.classList.toggle("active-phase", idx === currentIndex);
    });

    tabButtons.forEach((tab, idx) => {
      tab.classList.toggle("active", idx === currentIndex);
    });

    updateCurrentLabel();

    // Scroll vers le haut de la fiche
    const topOffset = navContainer.getBoundingClientRect().top + window.scrollY - 70;
    if (window.scrollY > topOffset) {
      window.scrollTo({ top: topOffset, behavior: "smooth" });
    }
    history.replaceState(null, null, `#phase-${currentIndex + 1}`);
  }

  function showAllPhases() {
    isSingleMode = false;
    document.body.classList.remove("mode-single-phase");
    btnAll.classList.add("active");
    btnAll.innerHTML = `<span>✔ Revenir au mode phase par phase</span>`;
    phases.forEach((p) => p.classList.add("active-phase"));
    tabButtons.forEach((tab) => tab.classList.remove("active"));
    const lbl = navTitle.querySelector(".phase-current-label");
    if (lbl) lbl.textContent = "Vue complète (toutes les phases affichées ensemble)";
    history.replaceState(null, null, "#toutes");
  }

  tabButtons.forEach((tab) => {
    tab.addEventListener("click", () => {
      const idx = parseInt(tab.getAttribute("data-index"), 10);
      switchPhase(idx);
    });
  });

  btnAll.addEventListener("click", () => {
    if (isSingleMode) {
      showAllPhases();
    } else {
      switchPhase(currentIndex);
    }
  });

  // Clavier : Alt + Flèche gauche / droite
  window.addEventListener("keydown", (e) => {
    if (e.target.tagName === "INPUT" || e.target.tagName === "TEXTAREA") return;
    if (e.key === "ArrowRight" && e.altKey) {
      if (isSingleMode && currentIndex < phases.length - 1) {
        switchPhase(currentIndex + 1);
      }
    } else if (e.key === "ArrowLeft" && e.altKey) {
      if (isSingleMode && currentIndex > 0) {
        switchPhase(currentIndex - 1);
      }
    }
  });

  // Gestion propre de l'impression : révéler toutes les phases
  window.addEventListener("beforeprint", () => {
    document.body.classList.remove("mode-single-phase");
    phases.forEach((p) => p.classList.add("active-phase"));
  });

  window.addEventListener("afterprint", () => {
    if (isSingleMode) {
      document.body.classList.add("mode-single-phase");
      phases.forEach((p, idx) => {
        p.classList.toggle("active-phase", idx === currentIndex);
      });
    }
  });

  // Hash URL au chargement
  const hash = window.location.hash;
  if (hash === "#toutes" || hash === "#all") {
    showAllPhases();
  } else if (hash.startsWith("#phase-")) {
    const num = parseInt(hash.replace("#phase-", ""), 10) - 1;
    if (!isNaN(num) && num >= 0 && num < phases.length) {
      switchPhase(num);
    } else {
      switchPhase(0);
    }
  } else {
    switchPhase(0);
  }
});
