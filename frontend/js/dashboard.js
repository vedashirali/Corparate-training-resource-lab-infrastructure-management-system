/**
 * CorpLab Nexus | Master Corporate Management Dashboard Logic
 * Dual-Engine Architecture: Connects to Spring Boot REST APIs with seamless live interactive data store.
 */

let ACTIVE_PORT = localStorage.getItem('corplab_backend_port') || '8088';
let API_BASE = `http://localhost:${ACTIVE_PORT}/api`;
let currentUser = null;
let isBackendConnected = false;
const isFileProtocol = window.location.protocol === 'file:';
const fetchCredentials = isFileProtocol ? 'omit' : 'include';

// Initialize Master Dynamic Seed Data for Client Data Engine
const INITIAL_DATA = {
    employees: [
        { id: 1, fullName: 'Rahul Sharma', username: 'rahul.s', email: 'rahul.s@corplab.com', department: 'Engineering', phone: '+1-555-0105', role: 'EMPLOYEE', status: 'ACTIVE' },
        { id: 2, fullName: 'Priya Patel', username: 'priya.p', email: 'priya.p@corplab.com', department: 'Cloud Architecture', phone: '+1-555-0106', role: 'EMPLOYEE', status: 'ACTIVE' },
        { id: 3, fullName: 'Vikram Malhotra', username: 'vikram.m', email: 'vikram.m@corplab.com', department: 'DevOps', phone: '+1-555-0107', role: 'EMPLOYEE', status: 'ACTIVE' },
        { id: 4, fullName: 'Neha Deshmukh', username: 'neha.d', email: 'neha.d@corplab.com', department: 'Data Science', phone: '+1-555-0108', role: 'EMPLOYEE', status: 'ACTIVE' }
    ],
    trainers: [
        { id: 101, fullName: 'David Kumar', username: 'david.k', email: 'david.kumar@corplab.com', department: 'Cloud & DevOps', phone: '+1-555-0102', role: 'TRAINER' },
        { id: 102, fullName: 'Elena Rostova', username: 'elena.r', email: 'elena.r@corplab.com', department: 'Data Science & AI', phone: '+1-555-0103', role: 'TRAINER' },
        { id: 103, fullName: 'Marcus Vance', username: 'marcus.v', email: 'marcus.v@corplab.com', department: 'Cybersecurity', phone: '+1-555-0104', role: 'TRAINER' }
    ],
    programs: [
        { id: 201, code: 'DEV-201', title: 'Cloud Infrastructure & Kubernetes Administration', category: 'Cloud Infrastructure', trainer: 'David Kumar', duration: '4 Weeks', enrolled: 28, status: 'ONGOING' },
        { id: 202, code: 'AI-301', title: 'Deep Learning & Neural Networks Acceleration', category: 'Artificial Intelligence', trainer: 'Elena Rostova', duration: '6 Weeks', enrolled: 22, status: 'OPEN' },
        { id: 203, code: 'SEC-401', title: 'Enterprise Zero Trust & Cyber Defense Architecture', category: 'Cybersecurity', trainer: 'Marcus Vance', duration: '3 Weeks', enrolled: 15, status: 'OPEN' },
        { id: 204, code: 'FSJ-101', title: 'Enterprise Java Full Stack with Spring Boot', category: 'Software Engineering', trainer: 'David Kumar', duration: '8 Weeks', enrolled: 35, status: 'ONGOING' }
    ],
    labs: [
        { id: 301, name: 'Cloud Lab A', location: 'Tech Tower B, Floor 3, Room 302', capacity: 35, description: 'High-bandwidth facility configured for Kubernetes and Cloud clustering.', status: 'ACTIVE' },
        { id: 302, name: 'AI Research Lab', location: 'Innovation Hub, Floor 4, Suite 410', capacity: 20, description: 'Climate-controlled lab equipped with high-density GPU compute racks.', status: 'ACTIVE' },
        { id: 303, name: 'Dev Lab B', location: 'Engineering Wing, Ground Floor, Room 105', capacity: 30, description: 'General development environment with dual-boot Linux/Windows workstations.', status: 'ACTIVE' }
    ],
    resources: [
        { id: 401, title: 'Kubernetes Master Node 01', category: 'Cloud Infrastructure', capacity: 64, status: 'AVAILABLE', description: 'Primary cluster controller with 16 vCPUs and Calico CNI' },
        { id: 402, title: 'NVIDIA RTX 4090 Deep Learning Rig', category: 'AI / GPU Compute', capacity: 128, status: 'RESERVED', description: 'Equipped with PyTorch 2.4 and CUDA 12.4 acceleration' },
        { id: 403, title: 'PostgreSQL HA DB Node', category: 'Database Systems', capacity: 32, status: 'AVAILABLE', description: 'High-availability replica node for lab testing and replication' },
        { id: 404, title: 'DevOps CI/CD Build Runner', category: 'DevOps & CI/CD', capacity: 64, status: 'AVAILABLE', description: 'Dedicated runner node for pipeline automation and Docker builds' }
    ],
    requests: [
        { id: 501, resourceName: 'NVIDIA RTX 4090 Deep Learning Rig', requesterName: 'Rahul Sharma', purpose: 'Distributed PyTorch model training and validation', date: '2026-11-20', timeSlot: '09:00 - 12:00', status: 'APPROVED' },
        { id: 502, resourceName: 'Kubernetes Master Node 01', requesterName: 'Priya Patel', purpose: 'Calico Network Policy and ingress testing', date: '2026-11-22', timeSlot: '14:00 - 17:00', status: 'PENDING' },
        { id: 503, resourceName: 'DevOps CI/CD Build Runner', requesterName: 'Vikram Malhotra', purpose: 'Pipeline stress testing and image build validation', date: '2026-11-24', timeSlot: '10:00 - 13:00', status: 'PENDING' }
    ],
    logs: [
        { id: 601, timestamp: new Date(Date.now() - 3600000).toISOString(), actor: 'admin', action: 'USER_LOGIN', details: 'Session authenticated successfully via Spring Security' },
        { id: 602, timestamp: new Date(Date.now() - 2400000).toISOString(), actor: 'admin', action: 'LAB_ALLOCATED', details: 'Approved Cloud Lab A for Kubernetes cohort DEV-201' },
        { id: 603, timestamp: new Date(Date.now() - 1200000).toISOString(), actor: 'admin', action: 'RESOURCE_RESERVED', details: 'NVIDIA RTX 4090 allocated to Rahul Sharma' }
    ]
};

function getStore(key) {
    const val = localStorage.getItem('corplab_store_' + key);
    if (!val) {
        localStorage.setItem('corplab_store_' + key, JSON.stringify(INITIAL_DATA[key] || []));
        return INITIAL_DATA[key] || [];
    }
    return JSON.parse(val);
}

function saveStore(key, data) {
    localStorage.setItem('corplab_store_' + key, JSON.stringify(data));
}

function logAudit(actor, action, details) {
    const logs = getStore('logs');
    logs.unshift({
        id: Date.now(),
        timestamp: new Date().toISOString(),
        actor: actor || (currentUser ? currentUser.username : 'admin'),
        action: action,
        details: details
    });
    saveStore('logs', logs);
}

document.addEventListener('DOMContentLoaded', async () => {
    // 0. Auto-synchronize master course and syllabus dataset
    const DATA_SCHEMA_VERSION = 'v3_original_enterprise_courses';
    if (localStorage.getItem('corplab_schema_ver') !== DATA_SCHEMA_VERSION) {
        localStorage.setItem('corplab_schema_ver', DATA_SCHEMA_VERSION);
        localStorage.setItem('corplab_store_programs', JSON.stringify(INITIAL_DATA.programs));
        localStorage.setItem('corplab_store_labs', JSON.stringify(INITIAL_DATA.labs));
        localStorage.setItem('corplab_store_resources', JSON.stringify(INITIAL_DATA.resources));
        localStorage.setItem('corplab_store_requests', JSON.stringify(INITIAL_DATA.requests));
        localStorage.setItem('corplab_store_trainers', JSON.stringify(INITIAL_DATA.trainers));
        localStorage.setItem('corplab_store_employees', JSON.stringify(INITIAL_DATA.employees));
        localStorage.setItem('corplab_master_syllabi', JSON.stringify(MASTER_SYLLABI));
    }

    // 1. Session check with fail-safe
    const sessionUser = sessionStorage.getItem('corplab_user');
    if (sessionUser) {
        try {
            currentUser = JSON.parse(sessionUser);
        } catch {
            currentUser = null;
        }
    }

    if (!currentUser) {
        // Default presentation user if accessed directly
        currentUser = {
            id: 1,
            username: 'admin',
            fullName: 'System Administrator',
            email: 'admin@corplab.com',
            role: 'ADMIN',
            department: 'IT Infrastructure',
            phone: '+1-555-0101'
        };
        sessionStorage.setItem('corplab_user', JSON.stringify(currentUser));
    }

    // Populate User Shell
    const initials = getInitials(currentUser.fullName || currentUser.username);
    const av = document.getElementById('user-avatar');
    if (av) av.textContent = initials;
    const nm = document.getElementById('user-display-name');
    if (nm) nm.textContent = currentUser.fullName || currentUser.username;
    const rl = document.getElementById('user-display-role');
    if (rl) rl.textContent = currentUser.role || 'ADMIN';

    // Synchronize Top Role Selector
    const roleSelect = document.getElementById('role-perspective-select');
    if (roleSelect && currentUser.role) {
        roleSelect.value = currentUser.role;
    }

    // Populate Profile Tab
    const pAv = document.getElementById('profile-avatar-large');
    if (pAv) pAv.textContent = initials;
    const pNm = document.getElementById('profile-full-name');
    if (pNm) pNm.textContent = currentUser.fullName || currentUser.username;
    const pEm = document.getElementById('profile-email');
    if (pEm) pEm.textContent = currentUser.email || 'admin@corplab.com';
    const pRl = document.getElementById('profile-badge-role');
    if (pRl) pRl.textContent = currentUser.role || 'ADMIN';
    const pDp = document.getElementById('profile-dept');
    if (pDp) pDp.textContent = currentUser.department || 'IT Infrastructure';
    const pPh = document.getElementById('profile-phone');
    if (pPh) pPh.textContent = currentUser.phone || '+1-555-0101';

    // Initialize Company Oversight & Notifications
    initNotifications();

    // Detect if live backend is online and monitor periodically
    checkBackendHealth();
    setInterval(checkBackendHealth, 4000);

    // Launch appropriate perspective view
    if (currentUser.role === 'EMPLOYEE') {
        switchView('student');
    } else if (currentUser.role === 'TRAINER') {
        switchView('teacher');
    } else {
        loadOverview();
    }
});

async function checkBackendHealth() {
    const healthPill = document.querySelector('.health-pill');
    const healthDot = document.querySelector('.health-dot');
    const healthText = document.getElementById('system-health-text');

    const candidatePorts = [8085, 8088, 8080, 8086];
    for (const port of candidatePorts) {
        try {
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), 2000);
            const res = await fetch(`http://localhost:${port}/api/dashboard/overview`, {
                signal: controller.signal,
                credentials: fetchCredentials
            });
            clearTimeout(timeoutId);
            if (res.ok) {
                ACTIVE_PORT = String(port);
                API_BASE = `http://localhost:${ACTIVE_PORT}/api`;
                localStorage.setItem('corplab_backend_port', ACTIVE_PORT);
                isBackendConnected = true;

                if (healthPill) {
                    healthPill.style.background = '#ecfdf5';
                    healthPill.style.border = '1px solid #a7f3d0';
                    healthPill.title = `Connected to Spring Boot on port ${port} -> MySQL (XAMPP)`;
                }
                if (healthDot) {
                    healthDot.style.background = '#10b981';
                }
                if (healthText) {
                    healthText.textContent = `MySQL Connected (${port})`;
                    healthText.style.color = '#065f46';
                }
                return true;
            }
        } catch {}
    }

    // Backend is offline
    isBackendConnected = false;
    if (healthPill) {
        healthPill.style.background = '#fee2e2';
        healthPill.style.border = '1px solid #fca5a5';
        healthPill.title = 'Spring Boot is OFFLINE! Start PlatformApplication in IntelliJ to connect to XAMPP MySQL.';
    }
    if (healthDot) {
        healthDot.style.background = '#ef4444';
    }
    if (healthText) {
        healthText.textContent = 'Spring Boot Offline (Run IntelliJ)';
        healthText.style.color = '#b91c1c';
    }
    return false;
}

function getInitials(name) {
    if (!name) return 'AD';
    const parts = name.trim().split(/\s+/);
    if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
    return name.substring(0, 2).toUpperCase();
}

function switchView(viewName) {
    document.querySelectorAll('.sidebar-menu-btn').forEach(btn => {
        btn.classList.toggle('active', btn.getAttribute('data-view') === viewName);
    });

    document.querySelectorAll('.view-panel').forEach(panel => {
        panel.style.display = 'none';
    });

    const target = document.getElementById(`view-${viewName}`);
    if (target) target.style.display = 'block';

    switch (viewName) {
        case 'overview': loadOverview(); break;
        case 'employees': loadEmployees(); break;
        case 'trainers': loadTrainers(); break;
        case 'programs': loadPrograms(); break;
        case 'labs': loadLabs(); break;
        case 'resources': loadResources(); break;
        case 'requests': loadRequests(); break;
        case 'reports': loadReports(); break;
        case 'logs': loadActivityLogs(); break;
        case 'student': loadStudentView(); break;
        case 'teacher': loadTeacherView(); break;
    }
}

// --------------------------------------------------------------------
// 1. DASHBOARD OVERVIEW & STATISTICS
// --------------------------------------------------------------------
async function loadOverview() {
    // 1. Try Backend
    let ov = null;
    let st = null;

    try {
        const [ovRes, statRes] = await Promise.all([
            fetch(`${API_BASE}/dashboard/overview`, { credentials: fetchCredentials }),
            fetch(`${API_BASE}/dashboard/statistics`, { credentials: fetchCredentials })
        ]);
        if (ovRes.ok) ov = await ovRes.json();
        if (statRes.ok) st = await statRes.json();
    } catch {}

    // Fallback counts from local store
    if (!ov) {
        const emps = getStore('employees');
        const trns = getStore('trainers');
        const prgs = getStore('programs');
        const labs = getStore('labs');
        const ress = getStore('resources');
        const reqs = getStore('requests');
        const logs = getStore('logs');

        ov = {
            totalEmployees: emps.length,
            totalTrainers: trns.length,
            totalPrograms: prgs.length,
            availableLabs: labs.filter(l => l.status === 'ACTIVE').length,
            totalResources: ress.length,
            pendingRequests: reqs.filter(r => r.status === 'PENDING').length,
            recentActivities: logs.slice(0, 6)
        };
    }

    if (!st) {
        st = {
            monthlyEnrollment: {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov'],
                values: [45, 62, 78, 95, 110, 134, 150, 168, 190, 215, 240]
            },
            labUtilization: {
                labels: ['Cloud Lab A', 'AI Research Lab', 'Dev Lab B'],
                values: [82, 94, 65]
            }
        };
    }

    // Populate Counters
    document.getElementById('card-employees').textContent = ov.totalEmployees;
    document.getElementById('card-trainers').textContent = ov.totalTrainers;
    document.getElementById('card-programs').textContent = ov.totalPrograms;
    document.getElementById('card-labs').textContent = ov.availableLabs;
    document.getElementById('card-resources').textContent = ov.totalResources;
    document.getElementById('card-requests').textContent = ov.pendingRequests;

    // Render Recent Activity Stream
    const stream = document.getElementById('overview-activity-stream');
    if (stream) {
        const activities = ov.recentActivities || getStore('logs');
        if (activities && activities.length > 0) {
            stream.innerHTML = activities.slice(0, 6).map(act => `
                <div style="padding:10px 14px; background:var(--bg-input); border-radius:6px; display:flex; justify-content:space-between; align-items:center; font-size:13px;">
                    <div>
                        <strong style="color:var(--primary);">${escapeHtml(act.actor)}</strong>: ${escapeHtml(act.details || act.action)}
                    </div>
                    <span style="font-size:11px; color:var(--text-muted);">${formatTimestamp(act.timestamp)}</span>
                </div>
            `).join('');
        } else {
            stream.innerHTML = '<p style="color:var(--text-muted); font-size:13px;">No recent operations recorded.</p>';
        }
    }

    renderEnrollmentChart(st.monthlyEnrollment);
    renderLabUtilization(st.labUtilization);
}

function renderEnrollmentChart(data) {
    const container = document.getElementById('chart-enrollment-bar');
    if (!container || !data) return;

    const maxVal = Math.max(...data.values, 250);
    container.innerHTML = data.labels.map((label, i) => {
        const val = data.values[i];
        const heightPct = Math.round((val / maxVal) * 100);
        return `
            <div style="display:flex; flex-direction:column; align-items:center; flex:1; height:100%; justify-content:flex-end;">
                <span style="font-size:11px; font-weight:700; color:var(--accent-cyan); margin-bottom:6px;">${val}</span>
                <div style="width:100%; max-width:32px; height:${heightPct}%; background:linear-gradient(180deg, var(--primary) 0%, rgba(59,130,246,0.3) 100%); border-radius:4px 4px 0 0;"></div>
                <span style="font-size:11px; color:var(--text-muted); margin-top:8px;">${label}</span>
            </div>
        `;
    }).join('');
}

function renderLabUtilization(data) {
    const container = document.getElementById('chart-lab-utilization');
    if (!container || !data) return;

    container.innerHTML = data.labels.map((lab, i) => {
        const pct = data.values[i];
        const barColor = pct > 85 ? 'var(--danger)' : pct > 70 ? 'var(--warning)' : 'var(--success)';
        return `
            <div>
                <div style="display:flex; justify-content:space-between; font-size:12px; margin-bottom:4px;">
                    <strong>${escapeHtml(lab)}</strong>
                    <span style="color:${barColor}; font-weight:700;">${pct}% Allocated</span>
                </div>
                <div style="width:100%; height:8px; background:var(--bg-input); border-radius:4px; overflow:hidden;">
                    <div style="width:${pct}%; height:100%; background:${barColor}; border-radius:4px;"></div>
                </div>
            </div>
        `;
    }).join('');
}

// --------------------------------------------------------------------
// 2. EMPLOYEE MANAGEMENT (LEARNING MEMBERS)
// --------------------------------------------------------------------
async function loadEmployees() {
    const tbody = document.getElementById('tbody-employees');
    tbody.innerHTML = '<tr><td colspan="7">Loading employees...</td></tr>';

    let list = null;
    try {
        const res = await fetch(`${API_BASE}/employees`, { credentials: fetchCredentials });
        if (res.ok) list = await res.json();
    } catch {}

    if (!list) list = getStore('employees');

    if (list.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7">No employees found. Click "Add Employee" above.</td></tr>';
        return;
    }

    tbody.innerHTML = list.map(emp => `
        <tr>
            <td><strong>${escapeHtml(emp.fullName)}</strong></td>
            <td><code>${escapeHtml(emp.username)}</code></td>
            <td>${escapeHtml(emp.email)}</td>
            <td>${escapeHtml(emp.department || 'Engineering')}</td>
            <td>${escapeHtml(emp.phone || '-')}</td>
            <td><span class="status-badge status-available">${emp.status || 'ACTIVE'}</span></td>
            <td>
                <button class="btn-tbl-action btn-tbl-delete" onclick="handleDeleteEmployee(${emp.id})">Delete</button>
            </td>
        </tr>
    `).join('');
}

async function handleSaveEmployee(e) {
    e.preventDefault();
    const payload = {
        fullName: document.getElementById('emp-name').value.trim(),
        username: document.getElementById('emp-username').value.trim(),
        email: document.getElementById('emp-email').value.trim(),
        department: document.getElementById('emp-dept').value,
        phone: document.getElementById('emp-phone').value.trim()
    };

    // Refresh connection status before attempting write
    await checkBackendHealth();

    let backendSaved = false;
    let backendErrorMsg = '';

    if (isBackendConnected) {
        try {
            const res = await fetch(`${API_BASE}/employees`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                credentials: fetchCredentials,
                body: JSON.stringify(payload)
            });
            if (res.ok) {
                backendSaved = true;
                const savedEmp = await res.json().catch(() => null);
                if (savedEmp && savedEmp.id) payload.id = savedEmp.id;
                showToast('✅ Saved to MySQL', `${payload.fullName} was written to MySQL 'users' table!`, 'student-alert');
            } else {
                const errData = await res.json().catch(() => ({}));
                backendErrorMsg = errData.message || `HTTP ${res.status}`;
            }
        } catch (err) {
            backendErrorMsg = err.message || 'Network request failed';
        }
    }

    if (!backendSaved) {
        if (!isBackendConnected) {
            showToast('⚠️ NOT Saved to MySQL', 'Spring Boot is OFFLINE! Start PlatformApplication in IntelliJ to save to MySQL.', 'admin-alert');
        } else {
            showToast('⚠️ Database Error', backendErrorMsg || 'Could not save employee to MySQL.', 'admin-alert');
        }
    }

    // Save to local reactive store
    const list = getStore('employees');
    if (!payload.id) payload.id = Date.now();
    payload.status = 'ACTIVE';
    list.unshift(payload);
    saveStore('employees', list);

    logAudit('admin', 'EMPLOYEE_CREATED', `Registered corporate learner: ${payload.fullName} (${payload.department})`);

    closeModal('employee-modal');
    e.target.reset();
    loadEmployees();
    loadOverview();
}

async function handleDeleteEmployee(id) {
    if (!confirm('Are you sure you want to delete this employee record?')) return;
    try {
        await fetch(`${API_BASE}/employees/${id}`, { method: 'DELETE', credentials: fetchCredentials });
    } catch {}

    const list = getStore('employees').filter(e => e.id !== id);
    saveStore('employees', list);
    logAudit('admin', 'EMPLOYEE_DELETED', `Removed member ID: #${id}`);
    loadEmployees();
    loadOverview();
}

// --------------------------------------------------------------------
// 3. TRAINER MANAGEMENT
// --------------------------------------------------------------------
async function loadTrainers() {
    const tbody = document.getElementById('tbody-trainers');
    tbody.innerHTML = '<tr><td colspan="6">Loading trainers...</td></tr>';

    let list = null;
    try {
        const res = await fetch(`${API_BASE}/trainers`, { credentials: fetchCredentials });
        if (res.ok) list = await res.json();
    } catch {}

    if (!list) list = getStore('trainers');

    if (list.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6">No trainers found. Click "Add Trainer".</td></tr>';
        return;
    }

    tbody.innerHTML = list.map(trn => `
        <tr>
            <td><strong>${escapeHtml(trn.fullName)}</strong></td>
            <td><span style="color:var(--accent-cyan); font-weight:600;">${escapeHtml(trn.department || 'Cloud & DevOps')}</span></td>
            <td>${escapeHtml(trn.email)}</td>
            <td>${escapeHtml(trn.phone || '-')}</td>
            <td><span class="status-badge status-approved">TRAINER</span></td>
            <td>
                <button class="btn-tbl-action btn-tbl-delete" onclick="handleDeleteTrainer(${trn.id})">Delete</button>
            </td>
        </tr>
    `).join('');
}

async function handleSaveTrainer(e) {
    e.preventDefault();
    const payload = {
        fullName: document.getElementById('trn-name').value.trim(),
        username: document.getElementById('trn-username').value.trim(),
        email: document.getElementById('trn-email').value.trim(),
        department: document.getElementById('trn-dept').value,
        phone: document.getElementById('trn-phone').value.trim()
    };

    await checkBackendHealth();

    let backendSaved = false;
    let backendErrorMsg = '';

    if (isBackendConnected) {
        try {
            const res = await fetch(`${API_BASE}/trainers`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                credentials: fetchCredentials,
                body: JSON.stringify(payload)
            });
            if (res.ok) {
                backendSaved = true;
                const savedTrn = await res.json().catch(() => null);
                if (savedTrn && savedTrn.id) payload.id = savedTrn.id;
                showToast('✅ Saved to MySQL', `Trainer ${payload.fullName} written to MySQL 'users' table!`, 'student-alert');
            } else {
                const errData = await res.json().catch(() => ({}));
                backendErrorMsg = errData.message || `HTTP ${res.status}`;
            }
        } catch (err) {
            backendErrorMsg = err.message || 'Network request failed';
        }
    }

    if (!backendSaved) {
        if (!isBackendConnected) {
            showToast('⚠️ NOT Saved to MySQL', 'Spring Boot is OFFLINE! Start PlatformApplication in IntelliJ to save to MySQL.', 'admin-alert');
        } else {
            showToast('⚠️ Database Error', backendErrorMsg || 'Could not save trainer to MySQL.', 'admin-alert');
        }
    }

    const list = getStore('trainers');
    if (!payload.id) payload.id = Date.now();
    payload.role = 'TRAINER';
    list.unshift(payload);
    saveStore('trainers', list);

    logAudit('admin', 'TRAINER_CREATED', `Appointed instructor: ${payload.fullName} (${payload.department})`);

    closeModal('trainer-modal');
    e.target.reset();
    loadTrainers();
    loadOverview();
}
async function handleDeleteTrainer(id) {
    if (!confirm('Are you sure you want to delete this trainer?')) return;
    try {
        await fetch(`${API_BASE}/trainers/${id}`, { method: 'DELETE', credentials: fetchCredentials });
    } catch {}

    const list = getStore('trainers').filter(t => t.id !== id);
    saveStore('trainers', list);
    loadTrainers();
    loadOverview();
}

// --------------------------------------------------------------------
// 4. TRAINING PROGRAMS
// --------------------------------------------------------------------
async function loadPrograms() {
    const tbody = document.getElementById('tbody-programs');
    tbody.innerHTML = '<tr><td colspan="8">Loading programs...</td></tr>';

    let list = null;
    try {
        const res = await fetch(`${API_BASE}/training-programs`, { credentials: fetchCredentials });
        if (res.ok) list = await res.json();
    } catch {}

    if (!list) list = getStore('programs');

    tbody.innerHTML = list.map(p => `
        <tr>
            <td><code>${escapeHtml(p.code || p.programCode)}</code></td>
            <td><strong>${escapeHtml(p.title)}</strong></td>
            <td><span style="color:var(--accent-cyan); font-weight:600;">${escapeHtml(p.category)}</span></td>
            <td>${escapeHtml(p.trainer || p.trainerName || '-')}</td>
            <td>${escapeHtml(p.duration || '4 Weeks')}</td>
            <td>${p.enrolled || p.enrolledCount || 20} Trainees</td>
            <td><span class="status-badge ${p.status === 'ONGOING' ? 'status-approved' : 'status-available'}">${p.status || 'OPEN'}</span></td>
            <td>
                <button class="btn-tbl-action btn-tbl-delete" onclick="handleDeleteProgram(${p.id})">Delete</button>
            </td>
        </tr>
    `).join('');
}

async function handleSaveProgram(e) {
    e.preventDefault();
    const progCode = document.getElementById('prog-code').value.trim();
    const progTrainer = document.getElementById('prog-trainer').value.trim();
    const payload = {
        code: progCode,
        programCode: progCode,
        title: document.getElementById('prog-title').value.trim(),
        category: document.getElementById('prog-category').value,
        trainer: progTrainer,
        trainerName: progTrainer,
        duration: document.getElementById('prog-duration').value.trim(),
        enrolled: Math.floor(Math.random() * 20) + 10,
        status: 'OPEN'
    };

    await checkBackendHealth();

    let backendSaved = false;
    let backendErrorMsg = '';

    if (isBackendConnected) {
        try {
            const res = await fetch(`${API_BASE}/training-programs`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                credentials: fetchCredentials,
                body: JSON.stringify(payload)
            });
            if (res.ok) {
                backendSaved = true;
                const savedProg = await res.json().catch(() => null);
                if (savedProg && savedProg.id) payload.id = savedProg.id;
                showToast('✅ Saved to MySQL', `Course ${payload.code} written to MySQL 'training_programs' table!`, 'student-alert');
            } else {
                const errData = await res.json().catch(() => ({}));
                backendErrorMsg = errData.message || `HTTP ${res.status}`;
            }
        } catch (err) {
            backendErrorMsg = err.message || 'Network request failed';
        }
    }

    if (!backendSaved) {
        if (!isBackendConnected) {
            showToast('⚠️ NOT Saved to MySQL', 'Spring Boot is OFFLINE! Start PlatformApplication in IntelliJ to save to MySQL.', 'admin-alert');
        } else {
            showToast('⚠️ Database Error', backendErrorMsg || 'Could not save training program to MySQL.', 'admin-alert');
        }
    }

    const list = getStore('programs');
    if (!payload.id) payload.id = Date.now();
    list.unshift(payload);
    saveStore('programs', list);

    logAudit('admin', 'PROGRAM_CREATED', `Published course syllabus: ${payload.code} - ${payload.title}`);

    closeModal('program-modal');
    e.target.reset();
    loadPrograms();
    loadOverview();
}

async function handleDeleteProgram(id) {
    if (!confirm('Are you sure you want to delete this training program?')) return;
    try {
        await fetch(`${API_BASE}/training-programs/${id}`, { method: 'DELETE', credentials: fetchCredentials });
    } catch {}

    const list = getStore('programs').filter(p => p.id !== id);
    saveStore('programs', list);
    loadPrograms();
    loadOverview();
}

// --------------------------------------------------------------------
// 5. LAB INFRASTRUCTURE
// --------------------------------------------------------------------
async function loadLabs() {
    const tbody = document.getElementById('tbody-labs');
    tbody.innerHTML = '<tr><td colspan="6">Loading labs...</td></tr>';

    let list = null;
    try {
        const res = await fetch(`${API_BASE}/labs`, { credentials: fetchCredentials });
        if (res.ok) list = await res.json();
    } catch {}

    if (!list) list = getStore('labs');

    tbody.innerHTML = list.map(l => `
        <tr>
            <td><strong>${escapeHtml(l.name || l.labName)}</strong></td>
            <td>${escapeHtml(l.location)}</td>
            <td><strong>${l.capacity}</strong> Workstations</td>
            <td><small style="color:var(--text-muted);">${escapeHtml(l.description || '')}</small></td>
            <td><span class="status-badge ${l.status === 'ACTIVE' ? 'status-available' : 'status-maintenance'}">${l.status}</span></td>
            <td>
                <button class="btn-tbl-action btn-tbl-delete" onclick="handleDeleteLab(${l.id})">Delete</button>
            </td>
        </tr>
    `).join('');
}

async function handleSaveLab(e) {
    e.preventDefault();
    const labNameVal = document.getElementById('lab-name').value.trim();
    const payload = {
        name: labNameVal,
        labName: labNameVal,
        location: document.getElementById('lab-loc').value.trim(),
        capacity: parseInt(document.getElementById('lab-cap').value) || 30,
        description: document.getElementById('lab-desc').value.trim(),
        status: 'ACTIVE'
    };

    await checkBackendHealth();

    let backendSaved = false;
    let backendErrorMsg = '';

    if (isBackendConnected) {
        try {
            const res = await fetch(`${API_BASE}/labs`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                credentials: fetchCredentials,
                body: JSON.stringify(payload)
            });
            if (res.ok) {
                backendSaved = true;
                const savedLab = await res.json().catch(() => null);
                if (savedLab && savedLab.id) payload.id = savedLab.id;
                showToast('✅ Saved to MySQL', `Lab ${payload.name} written to MySQL 'labs' table!`, 'student-alert');
            } else {
                const errData = await res.json().catch(() => ({}));
                backendErrorMsg = errData.message || `HTTP ${res.status}`;
            }
        } catch (err) {
            backendErrorMsg = err.message || 'Network request failed';
        }
    }

    if (!backendSaved) {
        if (!isBackendConnected) {
            showToast('⚠️ NOT Saved to MySQL', 'Spring Boot is OFFLINE! Start PlatformApplication in IntelliJ to save to MySQL.', 'admin-alert');
        } else {
            showToast('⚠️ Database Error', backendErrorMsg || 'Could not save lab to MySQL.', 'admin-alert');
        }
    }

    const list = getStore('labs');
    if (!payload.id) payload.id = Date.now();
    list.unshift(payload);
    saveStore('labs', list);

    logAudit('admin', 'LAB_CREATED', `Commissioned new laboratory venue: ${payload.name}`);

    closeModal('lab-modal');
    e.target.reset();
    loadLabs();
    loadOverview();
}

async function handleDeleteLab(id) {
    if (!confirm('Are you sure you want to delete this lab facility?')) return;
    try {
        await fetch(`${API_BASE}/labs/${id}`, { method: 'DELETE', credentials: fetchCredentials });
    } catch {}

    const list = getStore('labs').filter(l => l.id !== id);
    saveStore('labs', list);
    loadLabs();
    loadOverview();
}

// --------------------------------------------------------------------
// 6. RESOURCE MANAGEMENT
// --------------------------------------------------------------------
async function loadResources() {
    const tbody = document.getElementById('tbody-resources');
    tbody.innerHTML = '<tr><td colspan="6">Loading compute resources...</td></tr>';

    let list = null;
    try {
        const res = await fetch(`${API_BASE}/resources`, { credentials: fetchCredentials });
        if (res.ok) list = await res.json();
    } catch {}

    if (!list) list = getStore('resources');

    tbody.innerHTML = list.map(r => `
        <tr>
            <td><strong>${escapeHtml(r.title)}</strong></td>
            <td><span style="color:var(--accent-cyan); font-weight:600;">${escapeHtml(r.category)}</span></td>
            <td>${r.capacity} GB / vCPUs</td>
            <td>
                <span class="status-badge ${r.status === 'AVAILABLE' ? 'status-available' : r.status === 'RESERVED' ? 'status-pending' : 'status-maintenance'}">
                    ${r.status}
                </span>
            </td>
            <td><small style="color:var(--text-muted);">${escapeHtml(r.description || '')}</small></td>
            <td>
                <button class="btn-tbl-action btn-tbl-delete" onclick="handleDeleteResource(${r.id})">Delete</button>
            </td>
        </tr>
    `).join('');
}

async function handleSaveResource(e) {
    e.preventDefault();
    const payload = {
        title: document.getElementById('res-title').value.trim(),
        category: document.getElementById('res-category').value,
        capacity: parseInt(document.getElementById('res-capacity').value) || 32,
        status: document.getElementById('res-status').value,
        description: document.getElementById('res-desc').value.trim()
    };

    await checkBackendHealth();

    let backendSaved = false;
    let backendErrorMsg = '';

    if (isBackendConnected) {
        try {
            const res = await fetch(`${API_BASE}/resources`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                credentials: fetchCredentials,
                body: JSON.stringify(payload)
            });
            if (res.ok) {
                backendSaved = true;
                const savedRes = await res.json().catch(() => null);
                if (savedRes && savedRes.id) payload.id = savedRes.id;
                showToast('✅ Saved to MySQL', `${payload.title} written to MySQL 'lab_resources' table!`, 'student-alert');
            } else {
                const errData = await res.json().catch(() => ({}));
                backendErrorMsg = errData.message || `HTTP ${res.status}`;
            }
        } catch (err) {
            backendErrorMsg = err.message || 'Network request failed';
        }
    }

    if (!backendSaved) {
        if (!isBackendConnected) {
            showToast('⚠️ NOT Saved to MySQL', 'Spring Boot is OFFLINE! Start PlatformApplication in IntelliJ to save to MySQL.', 'admin-alert');
        } else {
            showToast('⚠️ Database Error', backendErrorMsg || 'Could not save compute resource to MySQL.', 'admin-alert');
        }
    }

    const list = getStore('resources');
    if (!payload.id) payload.id = Date.now();
    list.unshift(payload);
    saveStore('resources', list);

    logAudit('admin', 'RESOURCE_CREATED', `Added compute node: ${payload.title} (${payload.capacity} GB)`);

    closeModal('resource-modal');
    e.target.reset();
    loadResources();
    loadOverview();
}

async function handleDeleteResource(id) {
    if (!confirm('Are you sure you want to remove this compute resource?')) return;
    try {
        await fetch(`${API_BASE}/resources/${id}`, { method: 'DELETE', credentials: fetchCredentials });
    } catch {}

    const list = getStore('resources').filter(r => r.id !== id);
    saveStore('resources', list);
    loadResources();
    loadOverview();
}

// --------------------------------------------------------------------
// 7. RESOURCE REQUESTS
// --------------------------------------------------------------------
async function loadRequests() {
    const tbody = document.getElementById('tbody-requests');
    tbody.innerHTML = '<tr><td colspan="7">Loading requests...</td></tr>';

    let list = null;
    try {
        const res = await fetch(`${API_BASE}/resource-requests`, { credentials: fetchCredentials });
        if (res.ok) list = await res.json();
    } catch {}

    if (!list) list = getStore('requests');

    tbody.innerHTML = list.map(req => `
        <tr>
            <td><code>#REQ-${req.id}</code></td>
            <td><strong>${escapeHtml(req.resourceName)}</strong></td>
            <td>${escapeHtml(req.requesterName || 'Rahul Sharma')}</td>
            <td><small style="color:var(--text-muted);">${escapeHtml(req.purpose || '')}</small></td>
            <td>${escapeHtml(req.date || req.bookingDate || '')} (${escapeHtml(req.timeSlot || '09:00 - 12:00')})</td>
            <td>
                <span class="status-badge ${req.status === 'APPROVED' ? 'status-approved' : req.status === 'PENDING' ? 'status-pending' : 'status-rejected'}">
                    ${req.status}
                </span>
            </td>
            <td>
                ${req.status === 'PENDING' ? `
                    <button class="btn-tbl-action btn-tbl-edit" onclick="handleReviewRequest(${req.id}, 'APPROVED')">Approve</button>
                    <button class="btn-tbl-action btn-tbl-delete" onclick="handleReviewRequest(${req.id}, 'REJECTED')">Reject</button>
                ` : `<span style="font-size:12px; color:var(--text-muted); font-weight:600;">Processed</span>`}
            </td>
        </tr>
    `).join('');
}

async function handleSaveRequest(e) {
    e.preventDefault();
    const reqDateVal = document.getElementById('req-date').value;
    const payload = {
        resourceName: document.getElementById('req-res-name').value,
        date: reqDateVal,
        bookingDate: reqDateVal,
        timeSlot: document.getElementById('req-slot').value,
        purpose: document.getElementById('req-purpose').value.trim(),
        requesterName: currentUser ? (currentUser.fullName || currentUser.username) : 'Rahul Sharma',
        status: 'PENDING'
    };

    await checkBackendHealth();

    let backendSaved = false;
    let backendErrorMsg = '';

    if (isBackendConnected) {
        try {
            const res = await fetch(`${API_BASE}/resource-requests`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                credentials: fetchCredentials,
                body: JSON.stringify(payload)
            });
            if (res.ok) {
                backendSaved = true;
                const savedReq = await res.json().catch(() => null);
                if (savedReq && savedReq.id) payload.id = savedReq.id;
                showToast('✅ Saved to MySQL', `Booking for ${payload.resourceName} written to MySQL 'resource_requests' table!`, 'student-alert');
            } else {
                const errData = await res.json().catch(() => ({}));
                backendErrorMsg = errData.message || `HTTP ${res.status}`;
            }
        } catch (err) {
            backendErrorMsg = err.message || 'Network request failed';
        }
    }

    if (!backendSaved) {
        if (!isBackendConnected) {
            showToast('⚠️ NOT Saved to MySQL', 'Spring Boot is OFFLINE! Start PlatformApplication in IntelliJ to save to MySQL.', 'admin-alert');
        } else {
            showToast('⚠️ Database Error', backendErrorMsg || 'Could not save request to MySQL.', 'admin-alert');
        }
    }

    const list = getStore('requests');
    if (!payload.id) payload.id = Date.now();
    list.unshift(payload);
    saveStore('requests', list);

    logAudit(payload.requesterName, 'REQUEST_SUBMITTED', `Booked slot for: ${payload.resourceName}`);

    // Real-Time Company Oversight Notification
    triggerCompanyNotification({
        actor: payload.requesterName,
        role: 'STUDENT',
        action: 'LAB_HARDWARE_RESERVED',
        details: `${payload.requesterName} submitted a booking for ${payload.resourceName} (${payload.timeSlot})`,
        type: 'student-alert'
    });

    closeModal('request-modal');
    e.target.reset();
    loadRequests();
    loadOverview();
    if (document.getElementById('view-student') && document.getElementById('view-student').style.display !== 'none') {
        loadStudentView();
    }
}

async function handleReviewRequest(id, newStatus) {
    try {
        await fetch(`${API_BASE}/resource-requests/${id}/status`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            credentials: fetchCredentials,
            body: JSON.stringify({ status: newStatus })
        });
    } catch {}

    const list = getStore('requests');
    const item = list.find(r => r.id === id);
    if (item) {
        item.status = newStatus;
        saveStore('requests', list);
        logAudit('admin', 'REQUEST_' + newStatus, `Request #${id} marked as ${newStatus}`);

        // Notify company and trainee
        triggerCompanyNotification({
            actor: 'Company Admin',
            role: 'ADMIN',
            action: `REQUEST_${newStatus}`,
            details: `Company Admin ${newStatus.toLowerCase()} lab allocation for ${item.resourceName} (${item.requesterName})`,
            type: 'admin-alert'
        });
    }
    loadRequests();
    loadOverview();
    if (document.getElementById('view-student') && document.getElementById('view-student').style.display !== 'none') {
        loadStudentView();
    }
}

// --------------------------------------------------------------------
// 8. REPORTS & ANALYTICS
// --------------------------------------------------------------------
async function loadReports() {
    let trn = null;
    let lab = null;
    let res = null;

    try {
        const [tRes, lRes, rRes] = await Promise.all([
            fetch(`${API_BASE}/reports/training`, { credentials: fetchCredentials }),
            fetch(`${API_BASE}/reports/labs`, { credentials: fetchCredentials }),
            fetch(`${API_BASE}/reports/resources`, { credentials: fetchCredentials })
        ]);
        if (tRes.ok) trn = await tRes.json();
        if (lRes.ok) lab = await lRes.json();
        if (rRes.ok) res = await rRes.json();
    } catch {}

    if (!trn) {
        trn = {
            totalPrograms: 4,
            activeCohorts: 2,
            completionRate: '92.4%',
            averageAttendance: '88.5%',
            monthlyTrainedLearners: [45, 62, 78, 95, 110, 134, 150, 168, 190, 215, 240]
        };
    }

    if (!lab) {
        lab = {
            averageUtilizationRate: '78.6%',
            peakHours: '10:00 AM - 01:00 PM',
            facilityBreakdown: [
                { labName: 'Cloud Lab A', capacity: 35, allocatedHours: 142, utilization: '82%' },
                { labName: 'AI Research Lab', capacity: 20, allocatedHours: 188, utilization: '94%' },
                { labName: 'Dev Lab B', capacity: 30, allocatedHours: 98, utilization: '65%' }
            ]
        };
    }

    if (!res) {
        res = {
            totalAssets: 4,
            availableAssets: 3,
            totalRequests: 3,
            approvedRequests: 1,
            approvalRate: '66.7%'
        };
    }

    document.getElementById('report-training-container').innerHTML = `
        <div style="font-size:13px; line-height:1.7;">
            <div style="display:flex; justify-content:space-between; margin-bottom:8px;">
                <span>Program Completion Rate:</span>
                <strong style="color:var(--success); font-size:15px;">${trn.completionRate}</strong>
            </div>
            <div style="display:flex; justify-content:space-between; margin-bottom:8px;">
                <span>Average Learner Attendance:</span>
                <strong style="color:var(--accent-cyan); font-size:15px;">${trn.averageAttendance}</strong>
            </div>
            <div style="display:flex; justify-content:space-between;">
                <span>Active Syllabus Cohorts:</span>
                <strong>${trn.activeCohorts} Active Tracks</strong>
            </div>
        </div>
    `;

    document.getElementById('report-labs-container').innerHTML = `
        <div style="font-size:13px; line-height:1.7;">
            <div style="display:flex; justify-content:space-between; margin-bottom:8px;">
                <span>Average Facility Utilization:</span>
                <strong style="color:var(--primary); font-size:15px;">${lab.averageUtilizationRate}</strong>
            </div>
            <div style="display:flex; justify-content:space-between; margin-bottom:12px;">
                <span>Peak Daily Load:</span>
                <strong>${lab.peakHours}</strong>
            </div>
            <table class="enterprise-data-table" style="margin-top:10px;">
                <thead><tr><th>Facility</th><th>Capacity</th><th>Allocated</th><th>Load</th></tr></thead>
                <tbody>
                    ${lab.facilityBreakdown.map(f => `<tr><td>${f.labName}</td><td>${f.capacity}</td><td>${f.allocatedHours} hrs</td><td><span class="status-badge status-approved">${f.utilization}</span></td></tr>`).join('')}
                </tbody>
            </table>
        </div>
    `;

    document.getElementById('report-resources-container').innerHTML = `
        <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap:16px; margin-bottom:16px;">
            <div style="background:var(--bg-input); padding:12px; border-radius:6px;">
                <span style="color:var(--text-muted); font-size:11px; text-transform:uppercase;">Hardware Assets</span>
                <div style="font-size:22px; font-weight:800; color:#fff;">${res.totalAssets} Units</div>
            </div>
            <div style="background:var(--bg-input); padding:12px; border-radius:6px;">
                <span style="color:var(--text-muted); font-size:11px; text-transform:uppercase;">Available Right Now</span>
                <div style="font-size:22px; font-weight:800; color:var(--success);">${res.availableAssets} Units</div>
            </div>
            <div style="background:var(--bg-input); padding:12px; border-radius:6px;">
                <span style="color:var(--text-muted); font-size:11px; text-transform:uppercase;">Request Approval Rate</span>
                <div style="font-size:22px; font-weight:800; color:var(--accent-cyan);">${res.approvalRate}</div>
            </div>
        </div>
    `;
}

// --------------------------------------------------------------------
// 9. ACTIVITY AUDIT LOGS
// --------------------------------------------------------------------
async function loadActivityLogs() {
    const tbody = document.getElementById('tbody-logs');
    tbody.innerHTML = '<tr><td colspan="4">Loading audit logs...</td></tr>';

    let logs = null;
    try {
        const res = await fetch(`${API_BASE}/settings/logs`, { credentials: fetchCredentials });
        if (res.ok) logs = await res.json();
    } catch {}

    if (!logs) logs = getStore('logs');

    if (logs.length === 0) {
        tbody.innerHTML = '<tr><td colspan="4">No activity events recorded yet.</td></tr>';
        return;
    }

    tbody.innerHTML = logs.map(l => `
        <tr>
            <td style="font-family:'JetBrains Mono', monospace; font-size:11px; color:var(--text-muted);">${formatTimestamp(l.timestamp)}</td>
            <td><strong>${escapeHtml(l.actor)}</strong></td>
            <td><code>${escapeHtml(l.action)}</code></td>
            <td>${escapeHtml(l.details || '')}</td>
        </tr>
    `).join('');
}

// --------------------------------------------------------------------
// UTILITIES: Search, Modals, Logout
// --------------------------------------------------------------------
function filterTable(tableId, query) {
    const q = query.toLowerCase();
    const rows = document.querySelectorAll(`#${tableId} tbody tr`);
    rows.forEach(row => {
        row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
}

function openModal(id) {
    const m = document.getElementById(id);
    if (m) m.style.display = 'flex';
}

function closeModal(id) {
    const m = document.getElementById(id);
    if (m) m.style.display = 'none';
}

async function handleLogout() {
    try {
        await fetch(`${API_BASE}/auth/logout`, { method: 'POST', credentials: 'include' });
    } finally {
        sessionStorage.clear();
        window.location.href = 'login.html';
    }
}

function escapeHtml(str) {
    if (!str) return '';
    return String(str).replace(/[&<>'"]/g, tag => ({
        '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;'
    }[tag] || tag));
}

function formatTimestamp(isoStr) {
    if (!isoStr) return '';
    try {
        const d = new Date(isoStr);
        return d.toLocaleDateString() + ' ' + d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    } catch {
        return isoStr;
    }
}

// ====================================================================
// 9. ROLE PERSPECTIVE SWITCHER & MULTI-PORTAL ARCHITECTURE
// ====================================================================

function changeRolePerspective(role) {
    if (role === 'ADMIN') {
        currentUser = {
            id: 1,
            username: 'admin',
            fullName: 'System Administrator',
            email: 'admin@corplab.com',
            role: 'ADMIN',
            department: 'Corporate IT & Operations',
            phone: '+1-555-0101'
        };
        showToast('Perspective: Company Admin', 'Full administrative authority, infrastructure approvals, and company oversight feed active.', 'admin-alert');
        switchView('overview');
    } else if (role === 'TRAINER') {
        currentUser = {
            id: 101,
            username: 'david.k',
            fullName: 'Prof. David Kumar',
            email: 'david.kumar@corplab.com',
            role: 'TRAINER',
            department: 'Cloud & DevOps Faculty',
            phone: '+1-555-0102'
        };
        showToast('Perspective: Faculty / Trainer', 'Switched to Prof. David Kumar. You can now update cohort syllabi and grade trainees.', 'teacher-alert');
        switchView('teacher');
    } else if (role === 'EMPLOYEE') {
        currentUser = {
            id: 1,
            username: 'rahul.s',
            fullName: 'Rahul Sharma',
            email: 'rahul.s@corplab.com',
            role: 'EMPLOYEE',
            department: 'Engineering Trainee Cohort',
            phone: '+1-555-0105'
        };
        showToast('Perspective: Trainee / Student', 'Switched to Rahul Sharma. You can now browse enrolled courses and book compute rigs.', 'student-alert');
        switchView('student');
    }

    sessionStorage.setItem('corplab_user', JSON.stringify(currentUser));

    // Update shell user cards
    const initials = getInitials(currentUser.fullName || currentUser.username);
    const av = document.getElementById('user-avatar');
    if (av) av.textContent = initials;
    const nm = document.getElementById('user-display-name');
    if (nm) nm.textContent = currentUser.fullName || currentUser.username;
    const rl = document.getElementById('user-display-role');
    if (rl) rl.textContent = currentUser.role;

    const roleSelect = document.getElementById('role-perspective-select');
    if (roleSelect) roleSelect.value = role;
}

// ====================================================================
// 10. REAL-TIME COMPANY OVERSIGHT & NOTIFICATION ENGINE
// ====================================================================

function initNotifications() {
    let notifications = JSON.parse(localStorage.getItem('corplab_audit_notifications') || 'null');
    if (!notifications) {
        notifications = [
            {
                id: 1,
                title: 'Student Lab Reservation',
                actor: 'Rahul Sharma',
                role: 'STUDENT',
                message: 'Rahul Sharma submitted a booking for NVIDIA RTX 4090 Deep Learning Rig (09:00 - 12:00)',
                timestamp: new Date(Date.now() - 12 * 60000).toISOString(),
                type: 'student-alert',
                unread: true
            },
            {
                id: 2,
                title: 'Faculty Syllabus Update',
                actor: 'Prof. David Kumar',
                role: 'TRAINER',
                message: 'Prof. David Kumar published Module 4: "Calico CNI & Cluster Ingress" to DEV-201 syllabus',
                timestamp: new Date(Date.now() - 48 * 60000).toISOString(),
                type: 'teacher-alert',
                unread: true
            },
            {
                id: 3,
                title: 'Infrastructure Cluster Allocation',
                actor: 'System Administrator',
                role: 'ADMIN',
                message: 'Approved Cloud Lab A for 35 corporate trainees in enterprise Kubernetes track',
                timestamp: new Date(Date.now() - 110 * 60000).toISOString(),
                type: 'admin-alert',
                unread: false
            }
        ];
        localStorage.setItem('corplab_audit_notifications', JSON.stringify(notifications));
    }
    renderNotifications();
}

function renderNotifications() {
    const list = JSON.parse(localStorage.getItem('corplab_audit_notifications') || '[]');
    const badge = document.getElementById('notif-badge-count');
    const container = document.getElementById('notif-dropdown-list');

    const unreadCount = list.filter(n => n.unread).length;
    if (badge) {
        badge.textContent = unreadCount;
        badge.style.display = unreadCount > 0 ? 'inline-block' : 'none';
    }

    if (!container) return;

    if (list.length === 0) {
        container.innerHTML = '<div style="padding: 24px; text-align: center; color: var(--text-muted); font-size: 13px;">No active platform notifications.</div>';
        return;
    }

    container.innerHTML = list.slice(0, 10).map(n => {
        const iconBg = n.role === 'STUDENT' ? 'rgba(16, 185, 129, 0.2)' : (n.role === 'TRAINER' ? 'rgba(6, 182, 212, 0.2)' : 'rgba(59, 130, 246, 0.2)');
        const iconColor = n.role === 'STUDENT' ? '#10b981' : (n.role === 'TRAINER' ? '#06b6d4' : '#3b82f6');
        const roleLabel = n.role === 'STUDENT' ? 'STUDENT' : (n.role === 'TRAINER' ? 'TEACHER' : 'COMPANY');

        return `
            <div class="notification-item ${n.unread ? 'unread' : ''}">
                <div class="notif-icon-bubble" style="background:${iconBg}; color:${iconColor}; font-weight:800; font-size:11px;">
                    ${roleLabel[0]}
                </div>
                <div style="flex:1;">
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:2px;">
                        <span style="font-weight:700; color:${iconColor}; font-size:11px; text-transform:uppercase;">[${roleLabel}] ${escapeHtml(n.title)}</span>
                        <span style="color:var(--text-muted); font-size:10px;">${formatTimestamp(n.timestamp)}</span>
                    </div>
                    <div style="color:var(--text-primary); font-size:12px; line-height:1.4;">${escapeHtml(n.message)}</div>
                </div>
            </div>
        `;
    }).join('');
}

function triggerCompanyNotification({ actor, role, action, details, type }) {
    const list = JSON.parse(localStorage.getItem('corplab_audit_notifications') || '[]');
    const title = role === 'STUDENT' ? 'Student Action' : (role === 'TRAINER' ? 'Faculty Action' : 'Company Operation');

    const notifItem = {
        id: Date.now(),
        title: title,
        actor: actor || (currentUser ? currentUser.username : 'Unknown'),
        role: role || (currentUser ? currentUser.role : 'ADMIN'),
        action: action,
        message: details,
        timestamp: new Date().toISOString(),
        type: type || (role === 'STUDENT' ? 'student-alert' : (role === 'TRAINER' ? 'teacher-alert' : 'admin-alert')),
        unread: true
    };

    list.unshift(notifItem);
    localStorage.setItem('corplab_audit_notifications', JSON.stringify(list));

    // Show slide-in toast
    showToast(`[${role}] ${title}`, details, notifItem.type);

    // Update bell dropdown and badge
    renderNotifications();

    // Pulse animation on the bell
    const bellBtn = document.getElementById('btn-notification-bell');
    if (bellBtn) {
        bellBtn.style.transform = 'scale(1.15)';
        bellBtn.style.borderColor = 'var(--accent-cyan)';
        setTimeout(() => {
            bellBtn.style.transform = 'scale(1)';
            bellBtn.style.borderColor = '';
        }, 400);
    }
}

function toggleNotificationMenu() {
    const menu = document.getElementById('notif-dropdown-menu');
    if (!menu) return;
    const isShowing = menu.style.display === 'block';
    menu.style.display = isShowing ? 'none' : 'block';

    if (!isShowing) {
        // Mark all as read
        const list = JSON.parse(localStorage.getItem('corplab_audit_notifications') || '[]');
        list.forEach(item => item.unread = false);
        localStorage.setItem('corplab_audit_notifications', JSON.stringify(list));
        renderNotifications();
    }
}

function clearAllNotifications() {
    localStorage.setItem('corplab_audit_notifications', JSON.stringify([]));
    renderNotifications();
    showToast('Notifications Cleared', 'All activity alerts marked resolved.', 'default');
}

// Global click to close notification menu
document.addEventListener('click', (e) => {
    const wrapper = document.querySelector('.notification-wrapper');
    const menu = document.getElementById('notif-dropdown-menu');
    if (menu && wrapper && !wrapper.contains(e.target)) {
        menu.style.display = 'none';
    }
});

function showToast(title, message, type = 'default') {
    const container = document.getElementById('toast-container');
    if (!container) return;

    const toast = document.createElement('div');
    toast.className = `toast-card ${type}`;

    let iconSvg = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>';
    if (type === 'student-alert') {
        iconSvg = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#10b981" stroke-width="2"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>';
    } else if (type === 'teacher-alert') {
        iconSvg = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#06b6d4" stroke-width="2"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"></path><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"></path></svg>';
    } else if (type === 'admin-alert') {
        iconSvg = '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#f59e0b" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>';
    }

    toast.innerHTML = `
        <div style="flex-shrink:0; margin-top:2px;">${iconSvg}</div>
        <div style="flex:1;">
            <div style="font-weight:700; margin-bottom:3px; color:var(--text-primary); font-size:13px;">${escapeHtml(title)}</div>
            <div style="color:var(--text-secondary); font-size:12px; line-height:1.4;">${escapeHtml(message)}</div>
        </div>
        <button style="background:none; border:none; color:var(--text-muted); cursor:pointer; font-size:16px; margin-left:8px;" onclick="this.parentElement.remove()">&times;</button>
    `;

    container.appendChild(toast);

    setTimeout(() => {
        if (toast.parentElement) {
            toast.style.opacity = '0';
            toast.style.transform = 'translateX(100%)';
            toast.style.transition = 'all 0.3s ease-out';
            setTimeout(() => toast.remove(), 350);
        }
    }, 4500);
}

// ====================================================================
// 11. MASTER SYLLABUS DATASET & SPECIFICATIONS
// ====================================================================

const MASTER_SYLLABI = {
    'DEV-201': {
        code: 'DEV-201',
        title: 'Cloud Infrastructure & Kubernetes Administration',
        category: 'Cloud Infrastructure',
        trainer: 'Prof. David Kumar',
        duration: '4 Weeks (32 Hours)',
        level: 'Enterprise Advanced',
        modules: [
            { num: 'Module 1', title: 'Container Runtime Architecture, OCI Standards & Multi-Stage Builds', hours: '6 hrs', lab: 'Cloud Lab A' },
            { num: 'Module 2', title: 'Kubernetes Control Plane, Pod Scheduling & ReplicaSets', hours: '8 hrs', lab: 'Cloud Lab A' },
            { num: 'Module 3', title: 'Cluster Networking, CoreDNS, Ingress Controllers & Traefik', hours: '8 hrs', lab: 'Cloud Lab A' },
            { num: 'Module 4', title: 'Calico CNI Network Policies, StatefulSets & Persistent Storage', hours: '10 hrs', lab: 'Cloud Lab A' }
        ]
    },
    'FSJ-101': {
        code: 'FSJ-101',
        title: 'Enterprise Java Full Stack with Spring Boot',
        category: 'Software Engineering',
        trainer: 'Prof. David Kumar',
        duration: '8 Weeks (64 Hours)',
        level: 'Intermediate - Professional',
        modules: [
            { num: 'Module 1', title: 'Spring Core, ApplicationContext, Dependency Injection & Profiles', hours: '8 hrs', lab: 'Dev Lab B' },
            { num: 'Module 2', title: 'Spring Data JPA, Hibernate Mapping, HikariCP & MySQL 8 Schemas', hours: '12 hrs', lab: 'Dev Lab B' },
            { num: 'Module 3', title: 'RESTful API Engineering, DTO Validation & Exception Advisers', hours: '10 hrs', lab: 'Dev Lab B' },
            { num: 'Module 4', title: 'Spring Security 6 Architecture, JWT Token Filters & RBAC', hours: '14 hrs', lab: 'Dev Lab B' },
            { num: 'Module 5', title: 'Distributed Microservices, Eureka Discovery & Cloud Gateway', hours: '20 hrs', lab: 'Cloud Lab A' }
        ]
    },
    'AI-301': {
        code: 'AI-301',
        title: 'Deep Learning & Neural Networks Acceleration',
        category: 'Artificial Intelligence',
        trainer: 'Dr. Elena Rostova',
        duration: '6 Weeks (48 Hours)',
        level: 'Advanced Machine Learning',
        modules: [
            { num: 'Module 1', title: 'PyTorch 2.4 Tensors, CUDA 12.4 Kernels & Matrix Accelerators', hours: '10 hrs', lab: 'AI Research Lab' },
            { num: 'Module 2', title: 'Convolutional Networks, ResNet Architectures & Feature Extraction', hours: '12 hrs', lab: 'AI Research Lab' },
            { num: 'Module 3', title: 'Transformer Encoders, Multi-Head Attention & HuggingFace Models', hours: '14 hrs', lab: 'AI Research Lab' },
            { num: 'Module 4', title: 'Distributed Model Inference & High-Throughput TensorRT Engines', hours: '12 hrs', lab: 'AI Research Lab' }
        ]
    },
    'SEC-401': {
        code: 'SEC-401',
        title: 'Enterprise Zero Trust & Cyber Defense Architecture',
        category: 'Cybersecurity',
        trainer: 'Marcus Vance',
        duration: '3 Weeks (24 Hours)',
        level: 'Senior Security',
        modules: [
            { num: 'Module 1', title: 'Zero Trust Enclaves, mTLS & Secret Vault Management', hours: '6 hrs', lab: 'Cloud Lab A' },
            { num: 'Module 2', title: 'Vulnerability Scanning, OWASP API Top 10 & Penetration Vectors', hours: '8 hrs', lab: 'Dev Lab B' },
            { num: 'Module 3', title: 'SIEM Incident Telemetry, Kernel Auditd & eBPF Threat Hunting', hours: '10 hrs', lab: 'Cloud Lab A' }
        ]
    }
};

function getSyllabiStore() {
    const stored = localStorage.getItem('corplab_master_syllabi');
    if (!stored) {
        localStorage.setItem('corplab_master_syllabi', JSON.stringify(MASTER_SYLLABI));
        return MASTER_SYLLABI;
    }
    return JSON.parse(stored);
}

function saveSyllabiStore(data) {
    localStorage.setItem('corplab_master_syllabi', JSON.stringify(data));
}

// ====================================================================
// 12. STUDENT / TRAINEE LEARNING HUB IMPLEMENTATION
// ====================================================================

function loadStudentView() {
    const syllabi = getSyllabiStore();
    const grid = document.getElementById('student-courses-grid');
    if (!grid) return;

    const courseList = Object.values(syllabi);
    const progressMap = { 'FSJ-101': 75, 'DEV-201': 60, 'AI-301': 45, 'SEC-401': 25 };

    grid.innerHTML = courseList.map(c => {
        const pct = progressMap[c.code] || 50;
        return `
            <div class="student-course-card">
                <div>
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
                        <span class="status-badge status-approved" style="font-size:11px;">${escapeHtml(c.code)}</span>
                        <span style="font-size:11px; color:var(--accent-cyan); font-weight:700;">${escapeHtml(c.duration)}</span>
                    </div>
                    <h3 style="font-size:15px; font-weight:700; color:var(--text-primary); margin-bottom:6px;">${escapeHtml(c.title)}</h3>
                    <div style="font-size:12px; color:var(--text-secondary); margin-bottom:12px;">
                        Faculty: <strong>${escapeHtml(c.trainer)}</strong> &bull; Category: ${escapeHtml(c.category)}
                    </div>
                    
                    <div style="display:flex; justify-content:space-between; font-size:12px; margin-bottom:4px;">
                        <span style="color:var(--text-muted);">Curriculum Completion:</span>
                        <span style="font-weight:700; color:var(--accent-cyan);">${pct}%</span>
                    </div>
                    <div class="progress-bar-track">
                        <div class="progress-bar-fill" style="width: ${pct}%;"></div>
                    </div>
                    
                    <div style="margin-top:10px; font-size:11px; color:var(--text-muted);">
                        Latest Module: <strong>${escapeHtml(c.modules[c.modules.length - 1].title)}</strong>
                    </div>
                </div>

                <div style="display:flex; gap:8px; margin-top:16px;">
                    <button class="btn-action-primary" style="flex:1; padding:8px 12px; font-size:12px;" onclick="downloadCourseSyllabus('${c.code}')">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
                        View & Download (PDF / Excel)
                    </button>
                    <button class="btn-secondary" style="padding:8px 12px; font-size:12px;" onclick="openModal('request-modal')">
                        Book Lab
                    </button>
                </div>
            </div>
        `;
    }).join('');

    // Load Student Hardware Reservations Table
    const tbody = document.getElementById('tbody-student-reservations');
    if (!tbody) return;

    const allRequests = getStore('requests');
    const myRequests = allRequests.filter(r => 
        (r.requesterName || '').toLowerCase().includes('rahul') ||
        (r.requesterName || '').toLowerCase().includes(currentUser.username.toLowerCase())
    );

    const displayList = myRequests.length > 0 ? myRequests : allRequests;

    tbody.innerHTML = displayList.map(r => `
        <tr>
            <td><strong>${escapeHtml(r.resourceName)}</strong></td>
            <td>${escapeHtml(r.date || '2026-11-20')}</td>
            <td><code>${escapeHtml(r.timeSlot || '09:00 - 12:00')}</code></td>
            <td>${escapeHtml(r.purpose || 'Hands-on practice & lab simulation')}</td>
            <td>
                <span class="status-badge ${r.status === 'APPROVED' ? 'status-approved' : (r.status === 'PENDING' ? 'status-pending' : 'status-rejected')}">
                    ${r.status}
                </span>
            </td>
            <td>
                <button class="btn-tbl-action btn-tbl-delete" onclick="releaseStudentReservation(${r.id})">Release Slot</button>
            </td>
        </tr>
    `).join('');
}

let activeSyllabusCode = 'DEV-201';

function downloadCourseSyllabus(courseCode) {
    activeSyllabusCode = courseCode || 'DEV-201';
    const syllabi = getSyllabiStore();
    const course = syllabi[activeSyllabusCode] || syllabi['DEV-201'];

    document.getElementById('viewer-course-title').textContent = `${course.code}: ${course.title}`;
    
    const content = document.getElementById('viewer-syllabus-content');
    content.innerHTML = `
        <div style="background:#f8fafc; border:1px solid var(--border-color); padding:16px; border-radius:var(--radius-md); margin-bottom:18px;">
            <div style="display:flex; justify-content:space-between; margin-bottom:6px;">
                <span>Lead Instructor: <strong style="color:var(--text-primary);">${escapeHtml(course.trainer)}</strong></span>
                <span style="color:var(--primary); font-weight:700;">${escapeHtml(course.duration)}</span>
            </div>
            <div style="font-size:12px; color:var(--text-secondary);">
                Track Level: <strong>${escapeHtml(course.level)}</strong> &bull; Category: ${escapeHtml(course.category)}
            </div>
        </div>

        <h4 style="margin-bottom:12px; font-size:13px; text-transform:uppercase; letter-spacing:0.5px; color:var(--text-muted);">Curriculum Module Breakdown</h4>
        <div style="display:flex; flex-direction:column; gap:10px;">
            ${course.modules.map(m => `
                <div style="background:#ffffff; border:1px solid var(--border-color); border-radius:var(--radius-sm); padding:12px 16px; box-shadow:0 1px 2px rgba(0,0,0,0.03);">
                    <div style="display:flex; justify-content:space-between; font-weight:700; font-size:13px; color:var(--text-primary); margin-bottom:4px;">
                        <span>${escapeHtml(m.num)}: ${escapeHtml(m.title)}</span>
                        <span style="font-size:12px; color:var(--primary); font-weight:700;">${escapeHtml(m.hours)}</span>
                    </div>
                    <div style="font-size:12px; color:var(--text-muted);">
                        Hands-On Lab: <span style="color:var(--success); font-weight:600;">${escapeHtml(m.lab || 'Enterprise Lab Facility')}</span>
                    </div>
                </div>
            `).join('')}
        </div>
    `;

    openModal('syllabus-viewer-modal');
}

// --------------------------------------------------------------------
// UNIVERSAL EXPORT ENGINES: EXCEL (.CSV) & PDF REPORT GENERATORS
// --------------------------------------------------------------------

function exportDataToExcel(filename, headers, rows) {
    // Prepends UTF-8 BOM so Microsoft Excel opens cleanly
    let csvContent = "\uFEFF";
    csvContent += headers.map(h => `"${String(h).replace(/"/g, '""')}"`).join(",") + "\r\n";
    rows.forEach(row => {
        csvContent += row.map(cell => `"${String(cell !== undefined && cell !== null ? cell : '').replace(/"/g, '""')}"`).join(",") + "\r\n";
    });

    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.setAttribute("href", url);
    link.setAttribute("download", filename.endsWith('.csv') ? filename : filename + '.csv');
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
}

function printOrDownloadPdf(title, subtitle, contentHtml) {
    const printWindow = window.open('', '_blank', 'width=850,height=900');
    if (!printWindow) {
        alert('Please allow popups in your browser to view and save the PDF document.');
        return;
    }

    printWindow.document.write(`
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <title>${title}</title>
            <style>
                body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Arial, sans-serif; padding: 40px; color: #1e293b; background: #ffffff; line-height: 1.5; }
                .header { border-bottom: 2px solid #2563eb; padding-bottom: 18px; margin-bottom: 24px; display: flex; justify-content: space-between; align-items: flex-end; }
                .brand { font-size: 24px; font-weight: 800; color: #0f172a; }
                .brand span { color: #2563eb; }
                .meta { font-size: 11px; color: #64748b; text-align: right; }
                h1 { font-size: 20px; font-weight: 800; color: #0f172a; margin-top: 0; margin-bottom: 4px; }
                .subtitle { font-size: 13px; color: #475569; margin-bottom: 20px; }
                table { width: 100%; border-collapse: collapse; margin-top: 16px; font-size: 12px; }
                th { background: #f8fafc; color: #475569; font-weight: 700; text-align: left; padding: 10px 12px; border: 1px solid #e2e8f0; text-transform: uppercase; font-size: 11px; letter-spacing: 0.5px; }
                td { padding: 10px 12px; border: 1px solid #e2e8f0; color: #1e293b; }
                tr:nth-child(even) td { background: #f8fafc; }
                .badge { display: inline-block; padding: 3px 8px; border-radius: 4px; font-size: 10px; font-weight: 800; background: #eff6ff; color: #1d4ed8; text-transform: uppercase; }
                .footer { margin-top: 40px; padding-top: 14px; border-top: 1px solid #e2e8f0; font-size: 11px; color: #94a3b8; display: flex; justify-content: space-between; }
                @media print {
                    body { padding: 15px; }
                    .no-print { display: none !important; }
                }
            </style>
        </head>
        <body>
            <div class="header">
                <div>
                    <div class="brand">CorpLab <span>Nexus</span></div>
                    <div style="font-size: 12px; color: #64748b;">Enterprise Training Resource & Lab Infrastructure Platform</div>
                </div>
                <div class="meta">
                    <div>Generated: ${new Date().toLocaleDateString()} ${new Date().toLocaleTimeString()}</div>
                    <div>Security: Confidential / Enterprise Official</div>
                </div>
            </div>
            <h1>${escapeHtml(title)}</h1>
            <div class="subtitle">${escapeHtml(subtitle)}</div>
            ${contentHtml}
            <div class="footer">
                <span>CorpLab Nexus &bull; Verified Institutional Document</span>
                <span>Page 1 of 1</span>
            </div>
            <div class="no-print" style="margin-top: 30px; text-align: center;">
                <button onclick="window.print()" style="padding: 10px 24px; background: #2563eb; color: #ffffff; border: none; border-radius: 6px; font-weight: 700; cursor: pointer; font-size: 14px; box-shadow: 0 2px 6px rgba(37,99,235,0.3);">
                    Save as PDF / Print Document
                </button>
            </div>
            <script>
                window.onload = function() {
                    setTimeout(() => window.print(), 350);
                };
            </script>
        </body>
        </html>
    `);
    printWindow.document.close();
}

function downloadCurrentSyllabusPdf() {
    const syllabi = getSyllabiStore();
    const course = syllabi[activeSyllabusCode] || syllabi['DEV-201'];

    const contentHtml = `
        <div style="background:#f8fafc; border:1px solid #e2e8f0; border-radius:8px; padding:16px; margin-bottom:20px;">
            <div style="display:flex; justify-content:space-between; margin-bottom:8px;">
                <div><strong>Course Code:</strong> ${escapeHtml(course.code)}</div>
                <div><strong>Cohort Duration:</strong> ${escapeHtml(course.duration)}</div>
            </div>
            <div style="display:flex; justify-content:space-between; margin-bottom:8px;">
                <div><strong>Lead Instructor:</strong> ${escapeHtml(course.trainer)}</div>
                <div><strong>Target Level:</strong> ${escapeHtml(course.level)}</div>
            </div>
            <div><strong>Specialization Category:</strong> ${escapeHtml(course.category)}</div>
        </div>

        <h3 style="font-size:15px; color:#0f172a; margin-bottom:6px;">Official Curriculum Structure & Module Breakdown</h3>
        <p style="font-size:12px; color:#475569; margin-bottom:14px;">
            This course curriculum adheres to corporate production standards. Trainees execute hands-on architectural labs in dedicated environments.
        </p>

        <table>
            <thead>
                <tr>
                    <th style="width: 15%;">Module</th>
                    <th style="width: 50%;">Curriculum Specification & Topics</th>
                    <th style="width: 15%;">Duration</th>
                    <th style="width: 20%;">Allocated Facility</th>
                </tr>
            </thead>
            <tbody>
                ${course.modules.map(m => `
                    <tr>
                        <td><strong>${escapeHtml(m.num)}</strong></td>
                        <td>${escapeHtml(m.title)}</td>
                        <td><span class="badge">${escapeHtml(m.hours)}</span></td>
                        <td>${escapeHtml(m.lab || 'Enterprise Lab Facility')}</td>
                    </tr>
                `).join('')}
            </tbody>
        </table>

        <div style="margin-top:28px; background:#eff6ff; border:1px solid #bfdbfe; border-radius:8px; padding:14px; font-size:12px; color:#1e40af;">
            <strong>Corporate Accreditation:</strong> Completion of this curriculum certifies competency in ${escapeHtml(course.category)} for production deployment.
        </div>
    `;

    printOrDownloadPdf(`${course.code} - Official Course Syllabus`, course.title, contentHtml);
    showToast('PDF Generated', `Opening printable PDF specification for ${course.code}`, 'student-alert');
}

function exportCurrentSyllabusToExcel() {
    const syllabi = getSyllabiStore();
    const course = syllabi[activeSyllabusCode] || syllabi['DEV-201'];

    const headers = ["Course Code", "Course Title", "Faculty Instructor", "Duration", "Category", "Module Number", "Module Title", "Module Hours", "Lab Infrastructure"];
    const rows = course.modules.map(m => [
        course.code,
        course.title,
        course.trainer,
        course.duration,
        course.category,
        m.num,
        m.title,
        m.hours,
        m.lab || 'General Computing Lab'
    ]);

    exportDataToExcel(`CorpLab_Syllabus_${course.code}.csv`, headers, rows);
    showToast('Excel Export Ready', `Downloaded ${course.code} spreadsheet (.csv). Open in Microsoft Excel!`, 'student-alert');
}

function simulatePdfDownload() {
    downloadCurrentSyllabusPdf();
}

function exportProgramsToExcel() {
    const programs = getStore('programs');
    const headers = ["Program Code", "Program Title", "Category", "Lead Instructor", "Cohort Duration", "Enrolled Trainees", "Status"];
    const rows = programs.map(p => [
        p.code,
        p.title,
        p.category,
        p.trainer,
        p.duration,
        p.enrolled,
        p.status
    ]);

    exportDataToExcel("CorpLab_Enterprise_Programs.csv", headers, rows);
    showToast('Excel Export Ready', 'Downloaded training programs catalog (.csv) for Microsoft Excel.', 'default');
}

function exportResourcesToExcel() {
    const resources = getStore('resources');
    const headers = ["Resource ID", "Resource Name", "Category", "Specification / Capacity", "Status", "Technical Description"];
    const rows = resources.map(r => [
        r.id,
        r.title,
        r.category,
        r.capacity ? `${r.capacity} GB/Nodes` : 'Dedicated',
        r.status,
        r.description
    ]);

    exportDataToExcel("CorpLab_Hardware_Resources.csv", headers, rows);
    showToast('Excel Export Ready', 'Downloaded compute hardware inventory (.csv) for Microsoft Excel.', 'default');
}

function exportAllToExcel() {
    const programs = getStore('programs');
    const labs = getStore('labs');
    const resources = getStore('resources');
    const requests = getStore('requests');

    const headers = ["Asset Type", "Identifier / Name", "Category / Location", "Key Attributes / Specs", "Status"];
    const rows = [
        ...programs.map(p => ["Training Program", `${p.code}: ${p.title}`, p.category, `Trainer: ${p.trainer} | ${p.duration} | ${p.enrolled} trainees`, p.status]),
        ...labs.map(l => ["Lab Facility", l.name, l.location, `Capacity: ${l.capacity} workstations`, l.status]),
        ...resources.map(r => ["Compute Rig", r.title, r.category, r.description, r.status]),
        ...requests.map(q => ["Booking Request", q.resourceName, q.requesterName, `Slot: ${q.timeSlot} | Date: ${q.date}`, q.status])
    ];

    exportDataToExcel("CorpLab_Institutional_Master_Report.csv", headers, rows);
    showToast('Master Export Complete', 'All institutional data exported into Microsoft Excel format (.csv)!', 'default');
}

function downloadInstitutionalReportPdf() {
    const programs = getStore('programs');
    const labs = getStore('labs');
    const resources = getStore('resources');

    const contentHtml = `
        <div style="display:grid; grid-template-columns: repeat(4, 1fr); gap:12px; margin-bottom:24px;">
            <div style="background:#f8fafc; border:1px solid #e2e8f0; border-radius:6px; padding:12px; text-align:center;">
                <div style="font-size:22px; font-weight:bold; color:#0f172a;">${programs.length}</div>
                <div style="font-size:11px; color:#64748b; text-transform:uppercase;">Active Cohorts</div>
            </div>
            <div style="background:#f8fafc; border:1px solid #e2e8f0; border-radius:6px; padding:12px; text-align:center;">
                <div style="font-size:22px; font-weight:bold; color:#0f172a;">${labs.length}</div>
                <div style="font-size:11px; color:#64748b; text-transform:uppercase;">Lab Facilities</div>
            </div>
            <div style="background:#f8fafc; border:1px solid #e2e8f0; border-radius:6px; padding:12px; text-align:center;">
                <div style="font-size:22px; font-weight:bold; color:#0f172a;">${resources.length}</div>
                <div style="font-size:11px; color:#64748b; text-transform:uppercase;">Compute Rigs</div>
            </div>
            <div style="background:#f8fafc; border:1px solid #e2e8f0; border-radius:6px; padding:12px; text-align:center;">
                <div style="font-size:22px; font-weight:bold; color:#059669;">99.98%</div>
                <div style="font-size:11px; color:#64748b; text-transform:uppercase;">Infrastructure SLA</div>
            </div>
        </div>

        <h3 style="margin-top:20px; font-size:14px; border-bottom:1px solid #e2e8f0; padding-bottom:6px;">1. Corporate Training Cohorts Overview</h3>
        <table>
            <thead>
                <tr>
                    <th>Code</th>
                    <th>Course Title</th>
                    <th>Category</th>
                    <th>Lead Trainer</th>
                    <th>Enrolled</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                ${programs.map(p => `
                    <tr>
                        <td><strong>${escapeHtml(p.code)}</strong></td>
                        <td>${escapeHtml(p.title)}</td>
                        <td>${escapeHtml(p.category)}</td>
                        <td>${escapeHtml(p.trainer)}</td>
                        <td>${p.enrolled}</td>
                        <td><span class="badge">${p.status}</span></td>
                    </tr>
                `).join('')}
            </tbody>
        </table>

        <h3 style="margin-top:30px; font-size:14px; border-bottom:1px solid #e2e8f0; padding-bottom:6px;">2. Dedicated Lab Compute Infrastructure</h3>
        <table>
            <thead>
                <tr>
                    <th>Resource Name</th>
                    <th>Category</th>
                    <th>Status</th>
                    <th>Technical Profile</th>
                </tr>
            </thead>
            <tbody>
                ${resources.map(r => `
                    <tr>
                        <td><strong>${escapeHtml(r.title)}</strong></td>
                        <td>${escapeHtml(r.category)}</td>
                        <td><span class="badge">${r.status}</span></td>
                        <td>${escapeHtml(r.description)}</td>
                    </tr>
                `).join('')}
            </tbody>
        </table>

        <div style="margin-top:30px; border-top:1px solid #cbd5e1; padding-top:10px; font-size:11px; color:#64748b; display:flex; justify-content:space-between;">
            <div>Institutional Executive Verification Hash: <code>NX-SEC-2026-BCA-VERIFIED</code></div>
            <div>Sign-off: Corporate Director of Engineering & Labs</div>
        </div>
    `;

    printOrDownloadPdf("CorpLab Nexus Institutional Executive Report", "Comprehensive Infrastructure & Learning Analytics", contentHtml);
    showToast('Executive PDF Ready', 'Institutional management report opened in printable PDF format.', 'default');
}

function releaseStudentReservation(reqId) {
    const list = getStore('requests');
    const index = list.findIndex(r => r.id === reqId);
    let freedName = 'Hardware Rig';
    if (index !== -1) {
        freedName = list[index].resourceName;
        list.splice(index, 1);
        saveStore('requests', list);
    }

    logAudit(currentUser.username, 'LAB_SLOT_RELEASED', `Trainee released slot on ${freedName}`);

    triggerCompanyNotification({
        actor: currentUser.fullName || currentUser.username,
        role: 'STUDENT',
        action: 'LAB_SLOT_RELEASED',
        details: `${currentUser.fullName || currentUser.username} freed reservation for ${freedName}`,
        type: 'student-alert'
    });

    loadStudentView();
    loadRequests();
}

// ====================================================================
// 13. TEACHER / TRAINER FACULTY CONSOLE IMPLEMENTATION
// ====================================================================

function loadTeacherView() {
    const syllabi = getSyllabiStore();
    const tbody = document.getElementById('tbody-teacher-cohorts');
    if (!tbody) return;

    const courseList = Object.values(syllabi);

    tbody.innerHTML = courseList.map(c => `
        <tr>
            <td><strong>${escapeHtml(c.code)}</strong></td>
            <td>${escapeHtml(c.title)}</td>
            <td><span class="status-badge status-available" style="font-size:11px;">${escapeHtml(c.category)}</span></td>
            <td><strong style="color:var(--accent-cyan);">${escapeHtml(c.modules[c.modules.length - 1].num)}:</strong> ${escapeHtml(c.modules[c.modules.length - 1].title)}</td>
            <td>35 Trainees</td>
            <td><span class="status-badge status-approved">ACTIVE</span></td>
            <td>
                <button class="btn-tbl-action btn-tbl-edit" onclick="openSyllabusModalForCourse('${c.code}')">Update Syllabus</button>
            </td>
        </tr>
    `).join('');

    // Load Trainee Evaluation Roster
    const rBody = document.getElementById('tbody-teacher-students');
    if (!rBody) return;

    const trainees = [
        { name: 'Rahul Sharma', course: 'FSJ-101 (Spring Boot)', attendance: '98%', milestone: 'Milestone 4: Security Filters', grade: 'A+ (Distinction)' },
        { name: 'Priya Patel', course: 'DEV-201 (Kubernetes)', attendance: '95%', milestone: 'Milestone 3: Ingress & CNI', grade: 'A (High Pass)' },
        { name: 'Vikram Malhotra', course: 'AI-301 (Deep Learning)', attendance: '92%', milestone: 'Milestone 2: PyTorch CUDA', grade: 'A (High Pass)' },
        { name: 'Neha Deshmukh', course: 'FSJ-101 (Spring Boot)', attendance: '96%', milestone: 'Milestone 4: Security Filters', grade: 'A+ (Distinction)' }
    ];

    rBody.innerHTML = trainees.map(t => `
        <tr>
            <td><strong>${escapeHtml(t.name)}</strong></td>
            <td>${escapeHtml(t.course)}</td>
            <td><strong style="color:var(--success);">${escapeHtml(t.attendance)}</strong></td>
            <td>${escapeHtml(t.milestone)}</td>
            <td><span class="status-badge status-approved">${escapeHtml(t.grade)}</span></td>
            <td>
                <button class="btn-tbl-action btn-tbl-edit" onclick="gradeStudentLab('${t.name}', '${t.course}')">Evaluate Lab</button>
            </td>
        </tr>
    `).join('');
}

function openSyllabusModalForCourse(code) {
    const sel = document.getElementById('syl-prog-code');
    if (sel) sel.value = code;
    openModal('syllabus-modal');
}

function handleSaveSyllabus(e) {
    e.preventDefault();

    const progCode = document.getElementById('syl-prog-code').value;
    const modTitle = document.getElementById('syl-module-title').value.trim();
    const duration = document.getElementById('syl-duration').value.trim();
    const labVenue = document.getElementById('syl-lab').value.trim();
    const desc = document.getElementById('syl-desc').value.trim();

    const syllabi = getSyllabiStore();
    if (syllabi[progCode]) {
        const nextNum = 'Module ' + (syllabi[progCode].modules.length + 1);
        syllabi[progCode].modules.push({
            num: nextNum,
            title: modTitle,
            hours: duration,
            lab: labVenue,
            description: desc
        });
        saveSyllabiStore(syllabi);
    }

    logAudit('Prof. David Kumar', 'SYLLABUS_UPDATED', `Added ${modTitle} to ${progCode}`);

    // Company Oversight Notification
    triggerCompanyNotification({
        actor: 'Prof. David Kumar',
        role: 'TRAINER',
        action: 'SYLLABUS_MODIFIED',
        details: `Prof. David Kumar published new syllabus module: "${modTitle}" for cohort ${progCode}`,
        type: 'teacher-alert'
    });

    closeModal('syllabus-modal');
    e.target.reset();

    loadTeacherView();
    loadStudentView();
    loadOverview();
}

function gradeStudentLab(studentName, course) {
    const grade = prompt(`Enter assessment score for ${studentName} in ${course}:`, 'A+ (Distinction 98%)');
    if (!grade) return;

    logAudit('Prof. David Kumar', 'TRAINEE_EVALUATION', `Assessed ${studentName} with score: ${grade}`);

    triggerCompanyNotification({
        actor: 'Prof. David Kumar',
        role: 'TRAINER',
        action: 'TRAINEE_GRADED',
        details: `Faculty evaluated ${studentName} on practical lab milestone: ${grade}`,
        type: 'teacher-alert'
    });

    showToast('Trainee Graded', `Assessment score ${grade} submitted for ${studentName}.`, 'teacher-alert');
    loadTeacherView();
}
