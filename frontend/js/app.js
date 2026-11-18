/**
 * ====================================================================
 * CorpLab Nexus | Enterprise Frontend Management Logic
 * ====================================================================
 * 
 * Production-Grade Client Logic:
 * - 14 Compute Nodes across 3 Facilities (matching MySQL schema)
 * - 8 Training Tracks & 27 Scheduled Sessions
 * - 22 Bookings across Approval Workflows
 * - Role-Based Perspective (Trainee / Trainer / Admin)
 * - Live SSH Diagnostics Terminal Simulator
 */

const state = {
    currentRole: 'TRAINEE',
    currentFilter: 'ALL',
    currentLocation: 'ALL',
    searchQuery: '',
    viewMode: 'cards',

    facilities: [
        { id: 1, name: 'Cloud Lab A', location: 'Tech Tower B, Floor 3, Room 302', capacity: 35, nodes: 5, desc: 'High-bandwidth facility configured for Kubernetes and Cloud clustering.' },
        { id: 2, name: 'AI Research Lab', location: 'Innovation Hub, Floor 4, Suite 410', capacity: 20, nodes: 4, desc: 'Specialized climate-controlled lab equipped with high-density GPU compute racks.' },
        { id: 3, name: 'Dev Lab B', location: 'Engineering Wing, Ground Floor, Room 105', capacity: 30, nodes: 5, desc: 'General development environment with dual-boot Linux/Windows workstations.' }
    ],

    machines: [
        { id: 1, lab_name: 'Cloud Lab A', machine_name: 'SRV-K8S-MASTER', ip_address: '192.168.10.101', os_type: 'Ubuntu 22.04 LTS', ram_gb: 64, cpu_cores: 16, status: 'AVAILABLE', ram_util: 32 },
        { id: 2, lab_name: 'Cloud Lab A', machine_name: 'NODE-K8S-W1', ip_address: '192.168.10.102', os_type: 'Ubuntu 22.04 LTS', ram_gb: 32, cpu_cores: 8, status: 'AVAILABLE', ram_util: 68 },
        { id: 3, lab_name: 'Cloud Lab A', machine_name: 'NODE-K8S-W2', ip_address: '192.168.10.103', os_type: 'Ubuntu 22.04 LTS', ram_gb: 32, cpu_cores: 8, status: 'AVAILABLE', ram_util: 24 },
        { id: 7, lab_name: 'Cloud Lab A', machine_name: 'NODE-K8S-W3', ip_address: '192.168.10.104', os_type: 'Ubuntu 22.04 LTS', ram_gb: 32, cpu_cores: 8, status: 'MAINTENANCE', ram_util: 0 },
        { id: 8, lab_name: 'Cloud Lab A', machine_name: 'SRV-STORAGE-01', ip_address: '192.168.10.110', os_type: 'RHEL 9 Enterprise', ram_gb: 128, cpu_cores: 24, status: 'AVAILABLE', ram_util: 42 },

        { id: 4, lab_name: 'AI Research Lab', machine_name: 'GPU-RIG-RTX4090', ip_address: '192.168.20.201', os_type: 'Ubuntu 22.04 LTS', ram_gb: 128, cpu_cores: 32, status: 'AVAILABLE', ram_util: 85 },
        { id: 5, lab_name: 'AI Research Lab', machine_name: 'GPU-RIG-A100', ip_address: '192.168.20.202', os_type: 'Ubuntu 22.04 LTS', ram_gb: 256, cpu_cores: 64, status: 'MAINTENANCE', ram_util: 0 },
        { id: 9, lab_name: 'AI Research Lab', machine_name: 'GPU-RIG-H100', ip_address: '192.168.20.203', os_type: 'Ubuntu 22.04 LTS', ram_gb: 512, cpu_cores: 128, status: 'AVAILABLE', ram_util: 55 },
        { id: 10, lab_name: 'AI Research Lab', machine_name: 'AI-EDGE-JETSON', ip_address: '192.168.20.210', os_type: 'Ubuntu 22.04 LTS', ram_gb: 16, cpu_cores: 6, status: 'AVAILABLE', ram_util: 20 },

        { id: 6, lab_name: 'Dev Lab B', machine_name: 'DEV-WS-01', ip_address: '192.168.30.15', os_type: 'Windows Server 2022', ram_gb: 32, cpu_cores: 8, status: 'AVAILABLE', ram_util: 45 },
        { id: 11, lab_name: 'Dev Lab B', machine_name: 'DEV-WS-02', ip_address: '192.168.30.16', os_type: 'Windows Server 2022', ram_gb: 32, cpu_cores: 8, status: 'AVAILABLE', ram_util: 30 },
        { id: 12, lab_name: 'Dev Lab B', machine_name: 'DEV-WS-03', ip_address: '192.168.30.17', os_type: 'Ubuntu 22.04 LTS', ram_gb: 32, cpu_cores: 8, status: 'AVAILABLE', ram_util: 18 },
        { id: 13, lab_name: 'Dev Lab B', machine_name: 'DEV-WS-04', ip_address: '192.168.30.18', os_type: 'Windows 11 Enterprise', ram_gb: 16, cpu_cores: 4, status: 'RETIRED', ram_util: 0 },
        { id: 14, lab_name: 'Dev Lab B', machine_name: 'DEV-WS-05', ip_address: '192.168.30.19', os_type: 'Ubuntu 22.04 LTS', ram_gb: 32, cpu_cores: 8, status: 'AVAILABLE', ram_util: 25 }
    ],

    courses: [
        {
            id: 1, course_code: 'DEV-201', course_title: 'Cloud Infrastructure & Kubernetes Administration',
            category: 'Cloud Infrastructure', trainer: 'David Kumar', duration: 'Nov 01 - Nov 20, 2026',
            description: 'Hands-on enterprise curriculum covering container orchestration, pod autoscaling, ingress controllers, and cluster health diagnostics.',
            materials: [
                { title: 'Kubernetes Lab Setup Guide v1.2', format: 'PDF', size: '2.4 MB' },
                { title: 'Helm Charts Starter Repository', format: 'REPO', size: 'Git Repo' }
            ]
        },
        {
            id: 2, course_code: 'AI-301', course_title: 'Deep Learning & Neural Networks Acceleration',
            category: 'Artificial Intelligence', trainer: 'Elena Rostova', duration: 'Nov 05 - Nov 25, 2026',
            description: 'Intensive lab training exploring distributed model training, PyTorch CUDA optimization, and TensorRT inference pipeline deployment.',
            materials: [
                { title: 'PyTorch Multi-GPU Acceleration Walkthrough', format: 'LAB_GUIDE', size: '3.1 MB' },
                { title: 'Transformer Model Baseline Notebook', format: 'JUPYTER', size: '12.4 MB' }
            ]
        },
        {
            id: 3, course_code: 'SEC-401', course_title: 'Enterprise Zero Trust & Cyber Defense Architecture',
            category: 'Cybersecurity', trainer: 'Marcus Vance', duration: 'Nov 25 - Dec 15, 2026',
            description: 'Hands-on security auditing, firewall configuration, eBPF telemetry intrusion detection, and incident drills.',
            materials: [
                { title: 'Zero Trust Hardening Checklist', format: 'PDF', size: '1.9 MB' }
            ]
        },
        {
            id: 4, course_code: 'FSJ-101', course_title: 'Full Stack Enterprise Java with Spring Boot & Microservices',
            category: 'Software Engineering', trainer: 'Ananya Sen', duration: 'Dec 01 - Dec 24, 2026',
            description: 'Building decoupled, resilient REST APIs with Spring Data JPA, Hibernate, Resilience4j, and Apache Kafka.',
            materials: [
                { title: 'Microservices Reference Architecture', format: 'PDF', size: '4.2 MB' }
            ]
        }
    ],

    sessions: [
        { course: 'DEV-201', title: 'Cluster Networking, CoreDNS & Service Meshes', instructor: 'David Kumar', venue: 'Cloud Lab A', time: 'Nov 06, 2026 (09:00 - 12:00)', status: 'SCHEDULED' },
        { course: 'AI-301', title: 'PyTorch Tensor Fundamentals & Autograd Mechanics', instructor: 'Elena Rostova', venue: 'AI Research Lab', time: 'Nov 06, 2026 (14:00 - 17:00)', status: 'SCHEDULED' },
        { course: 'DEV-201', title: 'Persistent Volumes & StatefulSets Deployment', instructor: 'David Kumar', venue: 'Cloud Lab A', time: 'Nov 09, 2026 (09:00 - 12:00)', status: 'SCHEDULED' },
        { course: 'AI-301', title: 'Multi-GPU Distributed Data Parallel (DDP) Setup', instructor: 'Elena Rostova', venue: 'AI Research Lab', time: 'Nov 09, 2026 (14:00 - 17:00)', status: 'SCHEDULED' },
        { course: 'SEC-401', title: 'Zero Trust Network Architecture & Perimeters', instructor: 'Marcus Vance', venue: 'Cloud Lab A', time: 'Nov 26, 2026 (10:00 - 13:00)', status: 'SCHEDULED' },
        { course: 'FSJ-101', title: 'Spring Boot 3 Core Architecture & Virtual Threads', instructor: 'Ananya Sen', venue: 'Dev Lab B', time: 'Dec 02, 2026 (09:30 - 12:30)', status: 'SCHEDULED' }
    ],

    bookings: [
        { id: 'BK-101', machine: 'SRV-K8S-MASTER', user: 'Rahul Sharma', date: '2026-11-06', time: '09:00 - 12:00', purpose: 'K8S Pod Lifecycle and Multi-container pods testing', status: 'APPROVED' },
        { id: 'BK-102', machine: 'NODE-K8S-W2', user: 'Priya Patel', date: '2026-11-06', time: '09:00 - 12:00', purpose: 'CoreDNS and Calico Network Policy validation', status: 'APPROVED' },
        { id: 'BK-103', machine: 'GPU-RIG-RTX4090', user: 'Lucas Silva', date: '2026-11-06', time: '14:00 - 17:00', purpose: 'Distributed PyTorch fine-tuning on RTX4090 rig', status: 'APPROVED' },
        { id: 'BK-104', machine: 'DEV-WS-01', user: 'Vikram Malhotra', date: '2026-11-07', time: '10:00 - 13:00', purpose: 'Windows Server Active Directory LDAP federation testing', status: 'APPROVED' },
        { id: 'BK-105', machine: 'SRV-K8S-MASTER', user: 'Neha Deshmukh', date: '2026-11-12', time: '09:00 - 12:00', purpose: 'Kubernetes Helm Chart deployment practice', status: 'PENDING' },
        { id: 'BK-106', machine: 'GPU-RIG-RTX4090', user: 'Aiden Zhang', date: '2026-11-12', time: '14:00 - 17:00', purpose: 'Vision Transformer image classification training run', status: 'PENDING' },
        { id: 'BK-107', machine: 'GPU-RIG-A100', user: 'Ethan Brooks', date: '2026-11-08', time: '09:00 - 13:00', purpose: 'General browsing and coursework review', status: 'REJECTED' }
    ]
};

// ====================================================================
// DOM References
// ====================================================================
const infraCardsContainer = document.getElementById('infra-cards-container');
const infraTableContainer = document.getElementById('infra-table-container');
const infraTableBody = document.getElementById('infra-table-body');
const facilitiesContainer = document.getElementById('facilities-container');
const coursesContainer = document.getElementById('courses-container');
const sessionsTableBody = document.getElementById('sessions-table-body');
const bookingsTableBody = document.getElementById('bookings-table-body');

const navItems = document.querySelectorAll('.nav-item');
const tabViews = document.querySelectorAll('.tab-view');
const segButtons = document.querySelectorAll('.seg-btn');
const labLocationFilter = document.getElementById('lab-location-filter');
const globalSearch = document.getElementById('global-search');
const activeCrumb = document.getElementById('active-crumb');
const userRoleSelect = document.getElementById('user-role-select');
const userInitials = document.getElementById('user-initials');

const viewCardsBtn = document.getElementById('view-cards-btn');
const viewTableBtn = document.getElementById('view-table-btn');

// Modals
const reservationModal = document.getElementById('reservation-modal');
const closeModalX = document.getElementById('close-modal-x');
const btnCancelModal = document.getElementById('btn-cancel-modal');
const reservationForm = document.getElementById('reservation-form');
const resMachineSelect = document.getElementById('res-machine-select');
const resBookingDate = document.getElementById('res-booking-date');
const resUserName = document.getElementById('res-user-name');
const btnQuickReserve = document.getElementById('btn-quick-reserve');

// Terminal Simulator
const terminalModal = document.getElementById('terminal-modal');
const closeTerminalX = document.getElementById('close-terminal-x');
const terminalNodeTitle = document.getElementById('terminal-node-title');
const termIp = document.getElementById('term-ip');
const termRamLine = document.getElementById('term-ram-line');
const termCpuLine = document.getElementById('term-cpu-line');

const toastContainer = document.getElementById('toast-container');

// ====================================================================
// Render Functions
// ====================================================================

function updateKPICounters() {
    document.getElementById('kpi-total-nodes').textContent = state.machines.length;
    const availableNodes = state.machines.filter(m => m.status === 'AVAILABLE').length;
    document.getElementById('kpi-available-nodes').textContent = availableNodes;
    document.getElementById('kpi-available-subtext').textContent = `${state.machines.length - availableNodes} maintenance / retired`;
    document.getElementById('nav-count-labs').textContent = state.machines.length;
    document.getElementById('nav-count-bookings').textContent = state.bookings.length;
}

function getFilteredMachines() {
    return state.machines.filter(m => {
        const matchesStatus = (state.currentFilter === 'ALL') || (m.status === state.currentFilter);
        const matchesLocation = (state.currentLocation === 'ALL') || (m.lab_name === state.currentLocation);
        const q = state.searchQuery.toLowerCase();
        const matchesSearch = !q || m.machine_name.toLowerCase().includes(q) ||
                                   m.lab_name.toLowerCase().includes(q) ||
                                   m.os_type.toLowerCase().includes(q) ||
                                   m.ip_address.toLowerCase().includes(q);
        return matchesStatus && matchesLocation && matchesSearch;
    });
}

function renderComputeNodes() {
    const filtered = getFilteredMachines();

    // Render Cards
    infraCardsContainer.innerHTML = '';
    if (filtered.length === 0) {
        infraCardsContainer.innerHTML = `
            <div style="grid-column: 1/-1; text-align: center; padding: 3rem; color: #64748b;">
                <p style="font-size: 1rem; font-weight: 600;">No compute nodes match the active query.</p>
                <p style="font-size: 0.8rem; margin-top: 0.25rem;">Try adjusting filters or clear your search term.</p>
            </div>
        `;
    } else {
        filtered.forEach(node => {
            const card = document.createElement('div');
            card.className = 'node-card';

            let pillClass = 'available';
            let pillText = 'Available';
            let actionBtn = `<button class="btn btn-primary btn-xs" onclick="openReservationModal('${node.machine_name}')">Reserve Node</button>`;

            if (node.status === 'MAINTENANCE') {
                pillClass = 'maintenance';
                pillText = 'Maintenance';
                actionBtn = `<button class="btn btn-secondary btn-xs" disabled style="opacity: 0.6;">Offline</button>`;
            } else if (node.status === 'RETIRED') {
                pillClass = 'retired';
                pillText = 'Retired';
                actionBtn = `<button class="btn btn-secondary btn-xs" disabled style="opacity: 0.6;">Decommissioned</button>`;
            }

            const barColor = node.ram_util > 75 ? 'amber' : (node.ram_util > 0 ? 'blue' : 'green');

            card.innerHTML = `
                <div>
                    <div class="node-header">
                        <div class="node-title-group">
                            <div class="node-icon-box">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <rect x="2" y="2" width="20" height="8" rx="2" ry="2"></rect>
                                    <rect x="2" y="14" width="20" height="8" rx="2" ry="2"></rect>
                                    <line x1="6" y1="6" x2="6.01" y2="6"></line>
                                    <line x1="6" y1="18" x2="6.01" y2="18"></line>
                                </svg>
                            </div>
                            <div>
                                <div class="node-name">${node.machine_name}</div>
                                <div class="node-zone">${node.lab_name}</div>
                            </div>
                        </div>
                        <span class="status-pill ${pillClass}">
                            <span class="status-pill-dot"></span>
                            ${pillText}
                        </span>
                    </div>

                    <div class="node-telemetry">
                        <div class="telemetry-row">
                            <span>OS Engine:</span>
                            <span class="telemetry-val">${node.os_type}</span>
                        </div>
                        <div class="telemetry-row">
                            <span>Compute Cores:</span>
                            <span class="telemetry-val">${node.cpu_cores} vCPU</span>
                        </div>
                        <div class="telemetry-row">
                            <span>RAM Capacity:</span>
                            <span class="telemetry-val">${node.ram_gb} GB</span>
                        </div>
                        <div class="telemetry-bar-bg">
                            <div class="telemetry-bar-fill ${barColor}" style="width: ${node.ram_util || 10}%;"></div>
                        </div>
                    </div>
                </div>

                <div class="node-footer">
                    <span class="node-ip-badge">${node.ip_address}</span>
                    <div class="node-actions">
                        <button class="btn btn-secondary btn-xs" onclick="launchTerminalSimulator('${node.machine_name}', '${node.ip_address}', ${node.ram_gb}, ${node.cpu_cores})" title="Live SSH Connection Diagnostics">
                            SSH
                        </button>
                        ${actionBtn}
                    </div>
                </div>
            `;
            infraCardsContainer.appendChild(card);
        });
    }

    // Render Table View
    infraTableBody.innerHTML = '';
    filtered.forEach(node => {
        const tr = document.createElement('tr');
        let pillClass = node.status === 'AVAILABLE' ? 'available' : (node.status === 'MAINTENANCE' ? 'maintenance' : 'retired');
        let pillText = node.status === 'AVAILABLE' ? 'Available' : (node.status === 'MAINTENANCE' ? 'Maintenance' : 'Retired');

        tr.innerHTML = `
            <td><strong style="font-family: 'JetBrains Mono', monospace;">${node.machine_name}</strong></td>
            <td>${node.lab_name}</td>
            <td><code>${node.ip_address}</code></td>
            <td>${node.os_type}</td>
            <td><strong>${node.ram_gb} GB RAM</strong> / ${node.cpu_cores} Cores</td>
            <td><span class="status-pill ${pillClass}"><span class="status-pill-dot"></span>${pillText}</span></td>
            <td style="text-align: right;">
                <button class="btn btn-secondary btn-xs" onclick="launchTerminalSimulator('${node.machine_name}', '${node.ip_address}', ${node.ram_gb}, ${node.cpu_cores})">SSH</button>
                ${node.status === 'AVAILABLE' ? `<button class="btn btn-primary btn-xs" onclick="openReservationModal('${node.machine_name}')">Reserve</button>` : ''}
            </td>
        `;
        infraTableBody.appendChild(tr);
    });
}

function renderFacilities() {
    facilitiesContainer.innerHTML = '';
    state.facilities.forEach(f => {
        const card = document.createElement('div');
        card.className = 'facility-card';
        card.innerHTML = `
            <span class="facility-badge">Active Facility</span>
            <h3 class="facility-title">${f.name}</h3>
            <div class="facility-location">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>
                ${f.location}
            </div>
            <p class="facility-desc">${f.desc}</p>
            <div class="facility-metrics">
                <div>
                    <div class="f-metric-val">${f.nodes} Nodes</div>
                    <div class="f-metric-lbl">Configured Compute</div>
                </div>
                <div>
                    <div class="f-metric-val">${f.capacity} Seats</div>
                    <div class="f-metric-lbl">Room Capacity</div>
                </div>
            </div>
        `;
        facilitiesContainer.appendChild(card);
    });
}

function renderCourses() {
    coursesContainer.innerHTML = '';
    state.courses.forEach(course => {
        const card = document.createElement('div');
        card.className = 'course-card-enterprise';

        const materialsHtml = course.materials.map(mat => `
            <a href="#" class="res-chip" onclick="event.preventDefault(); showToast('Simulating Download: ${mat.title} (${mat.size})', 'info');">
                <span class="res-format-pill">${mat.format}</span>
                <span>${mat.title}</span>
                <span style="font-size: 0.7rem; color: #94a3b8; margin-left: 0.25rem;">[${mat.size}]</span>
            </a>
        `).join('');

        card.innerHTML = `
            <div class="course-top-row">
                <div>
                    <span class="course-badge">${course.course_code}</span>
                    <h3 class="course-title-text">${course.course_title}</h3>
                </div>
                <button class="btn btn-secondary btn-xs" onclick="showToast('Syllabus exported for ${course.course_code}', 'success')">
                    Export Syllabus
                </button>
            </div>
            <p class="course-desc-text">${course.description}</p>
            <div class="course-meta-tags">
                <span>👨‍🏫 Lead Trainer: <strong>${course.trainer}</strong></span>
                <span>🗓️ Schedule: <strong>${course.duration}</strong></span>
                <span>🏷️ Track: <strong>${course.category}</strong></span>
            </div>
            <div class="resources-list-box">
                <div class="res-headline">Course Materials & Lab Repositories (${course.materials.length})</div>
                <div class="res-pills-wrap">
                    ${materialsHtml}
                </div>
            </div>
        `;
        coursesContainer.appendChild(card);
    });
}

function renderSessions() {
    sessionsTableBody.innerHTML = '';
    state.sessions.forEach(s => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td><span class="course-badge">${s.course}</span></td>
            <td><strong>${s.title}</strong></td>
            <td>${s.instructor}</td>
            <td>${s.venue}</td>
            <td><span style="font-family: 'JetBrains Mono', monospace; font-size: 0.8rem; background: #f1f5f9; padding: 2px 6px; border-radius: 4px;">${s.time}</span></td>
            <td><span class="status-pill available"><span class="status-pill-dot"></span>${s.status}</span></td>
        `;
        sessionsTableBody.appendChild(tr);
    });
}

function renderBookings() {
    bookingsTableBody.innerHTML = '';
    state.bookings.forEach(b => {
        const tr = document.createElement('tr');
        let pillClass = b.status === 'APPROVED' ? 'available' : (b.status === 'PENDING' ? 'maintenance' : 'retired');

        tr.innerHTML = `
            <td><strong style="font-family: 'JetBrains Mono', monospace; color: #2563eb;">${b.id}</strong></td>
            <td><code>${b.machine}</code></td>
            <td><strong>${b.user}</strong></td>
            <td>${b.date}</td>
            <td><span style="font-family: 'JetBrains Mono', monospace; font-size: 0.8rem; background: #f1f5f9; padding: 2px 6px; border-radius: 4px;">${b.time}</span></td>
            <td>${b.purpose}</td>
            <td><span class="status-pill ${pillClass}"><span class="status-pill-dot"></span>${b.status}</span></td>
            <td style="text-align: right;">
                <button class="btn btn-secondary btn-xs" onclick="showToast('Audit record verified for ${b.id}', 'info')">Audit</button>
            </td>
        `;
        bookingsTableBody.appendChild(tr);
    });
}

// ====================================================================
// Modals & Handlers
// ====================================================================

window.openReservationModal = function(preselectedMachine = null) {
    resMachineSelect.innerHTML = '';
    const available = state.machines.filter(m => m.status === 'AVAILABLE');

    if (available.length === 0) {
        resMachineSelect.innerHTML = `<option value="">No nodes currently available</option>`;
    } else {
        available.forEach(m => {
            const opt = document.createElement('option');
            opt.value = m.machine_name;
            opt.textContent = `${m.machine_name} (${m.lab_name} - ${m.ram_gb}GB RAM / ${m.cpu_cores} Cores)`;
            if (preselectedMachine && preselectedMachine === m.machine_name) {
                opt.selected = true;
            }
            resMachineSelect.appendChild(opt);
        });
    }

    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    resBookingDate.value = tomorrow.toISOString().split('T')[0];

    reservationModal.classList.add('active');
};

function closeReservationModal() {
    reservationModal.classList.remove('active');
}

window.launchTerminalSimulator = function(machineName, ip, ram, cores) {
    terminalNodeTitle.textContent = `SSH Session: developer@${machineName}`;
    termIp.textContent = ip;
    termRamLine.textContent = `RAM: ${ram} GB Total (${Math.floor(ram * 0.65)} GB Free)`;
    termCpuLine.textContent = `CPU: ${cores} Cores | Load Average: 0.12, 0.18, 0.15`;
    terminalModal.classList.add('active');
};

function closeTerminalModal() {
    terminalModal.classList.remove('active');
}

function showToast(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = 'toast';
    toast.innerHTML = `
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="12" cy="12" r="10"></circle>
            <line x1="12" y1="16" x2="12" y2="12"></line>
            <line x1="12" y1="8" x2="12.01" y2="8"></line>
        </svg>
        <span>${message}</span>
    `;
    toastContainer.appendChild(toast);
    setTimeout(() => {
        toast.style.opacity = '0';
        toast.style.transform = 'translateY(10px)';
        setTimeout(() => toast.remove(), 250);
    }, 3200);
}

// ====================================================================
// Event Listeners
// ====================================================================

navItems.forEach(item => {
    item.addEventListener('click', () => {
        navItems.forEach(btn => btn.classList.remove('active'));
        tabViews.forEach(view => view.classList.remove('active'));

        item.classList.add('active');
        const targetTab = item.getAttribute('data-tab');
        document.getElementById(targetTab).classList.add('active');

        const titleSpan = item.querySelector('span');
        if (titleSpan) activeCrumb.textContent = titleSpan.textContent;
    });
});

segButtons.forEach(btn => {
    btn.addEventListener('click', () => {
        segButtons.forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        state.currentFilter = btn.getAttribute('data-filter');
        renderComputeNodes();
    });
});

labLocationFilter.addEventListener('change', (e) => {
    state.currentLocation = e.target.value;
    renderComputeNodes();
});

globalSearch.addEventListener('input', (e) => {
    state.searchQuery = e.target.value;
    renderComputeNodes();
});

viewCardsBtn.addEventListener('click', () => {
    viewCardsBtn.classList.add('active');
    viewTableBtn.classList.remove('active');
    infraCardsContainer.classList.remove('hidden');
    infraTableContainer.classList.add('hidden');
});

viewTableBtn.addEventListener('click', () => {
    viewTableBtn.classList.add('active');
    viewCardsBtn.classList.remove('active');
    infraCardsContainer.classList.add('hidden');
    infraTableContainer.classList.remove('hidden');
});

closeModalX.addEventListener('click', closeReservationModal);
btnCancelModal.addEventListener('click', closeReservationModal);
closeTerminalX.addEventListener('click', closeTerminalModal);
btnQuickReserve.addEventListener('click', () => openReservationModal());

reservationForm.addEventListener('submit', (e) => {
    e.preventDefault();

    const selectedMachine = resMachineSelect.value;
    const userName = resUserName.value;
    const bookingDate = resBookingDate.value;
    const startTime = document.getElementById('res-start-time').value;
    const endTime = document.getElementById('res-end-time').value;
    const purpose = document.getElementById('res-purpose').value;

    if (!selectedMachine) {
        showToast('Please select a valid compute node.', 'error');
        return;
    }

    const newBooking = {
        id: `BK-${100 + state.bookings.length + 1}`,
        machine: selectedMachine,
        user: userName,
        date: bookingDate,
        time: `${startTime} - ${endTime}`,
        purpose: purpose,
        status: 'PENDING'
    };

    state.bookings.unshift(newBooking);

    updateKPICounters();
    renderComputeNodes();
    renderBookings();
    closeReservationModal();

    showToast(`🎉 Reservation request submitted! Ref #${newBooking.id} is PENDING admin approval`, 'success');

    const bookingsNav = document.querySelector('[data-tab="tab-bookings"]');
    if (bookingsNav) bookingsNav.click();
});

userRoleSelect.addEventListener('change', (e) => {
    const role = e.target.value;
    state.currentRole = role;

    if (role === 'TRAINEE') {
        userInitials.textContent = 'RS';
        resUserName.value = 'Rahul Sharma';
        showToast('Active Profile: Rahul Sharma (Trainee)', 'info');
    } else if (role === 'TRAINER') {
        userInitials.textContent = 'DK';
        resUserName.value = 'David Kumar';
        showToast('Active Profile: David Kumar (Trainer)', 'info');
    } else {
        userInitials.textContent = 'SJ';
        resUserName.value = 'Sarah Jenkins';
        showToast('Active Profile: Sarah Jenkins (Lab Admin)', 'info');
    }
});

document.getElementById('btn-export-csv').addEventListener('click', () => {
    showToast('Exporting lab_bookings_audit.csv directly from database...', 'success');
});

window.addEventListener('keydown', (e) => {
    if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
        e.preventDefault();
        globalSearch.focus();
    }
});

document.addEventListener('DOMContentLoaded', () => {
    updateKPICounters();
    renderComputeNodes();
    renderFacilities();
    renderCourses();
    renderSessions();
    renderBookings();
    console.log('CorpLab Nexus Console initialized without internal schema tabs.');
});
