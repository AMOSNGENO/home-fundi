class DemoDestination {
  const DemoDestination({
    required this.label,
    required this.path,
    required this.description,
  });

  final String label;
  final String path;
  final String description;
}

const demoPublicDestinations = <DemoDestination>[
  DemoDestination(
    label: 'Onboarding',
    path: '/onboarding',
    description: 'Welcome and choose a flow.',
  ),
  DemoDestination(
    label: 'Login',
    path: '/login',
    description: 'Sign in entry point.',
  ),
  DemoDestination(
    label: 'OTP',
    path: '/otp',
    description: 'Verification screen.',
  ),
  DemoDestination(
    label: 'Home',
    path: '/home',
    description: 'Main demo dashboard.',
  ),
  DemoDestination(
    label: 'Bookings',
    path: '/bookings',
    description: 'Customer booking list.',
  ),
  DemoDestination(
    label: 'Messages',
    path: '/messages',
    description: 'Conversation inbox.',
  ),
];

const demoAdminDestinations = <DemoDestination>[
  DemoDestination(
    label: 'Admin',
    path: '/admin',
    description: 'Admin landing page.',
  ),
  DemoDestination(
    label: 'Admin Bookings',
    path: '/admin/bookings',
    description: 'Manage booking queue.',
  ),
  DemoDestination(
    label: 'Admin Technicians',
    path: '/admin/technicians',
    description: 'Manage technician roster.',
  ),
  DemoDestination(
    label: 'Admin Settings',
    path: '/admin/settings',
    description: 'Configuration and toggles.',
  ),
];

const demoTechnicianDestinations = <DemoDestination>[
  DemoDestination(
    label: 'Technician',
    path: '/technician',
    description: 'Technician dashboard.',
  ),
  DemoDestination(
    label: 'Active Job',
    path: '/technician/active',
    description: 'Current assigned job.',
  ),
  DemoDestination(
    label: 'Earnings',
    path: '/technician/earnings',
    description: 'Performance and payouts.',
  ),
  DemoDestination(
    label: 'Profile',
    path: '/technician/profile',
    description: 'Profile and availability.',
  ),
];