# frozen_string_literal: true

# ==================================================================
#  RemotelyYours seed data
#  Run with: rails db:seed
# ==================================================================

puts "Seeding RemotelyYours database..."

# --- Demo User ---
demo_user = User.find_or_initialize_by(email: "demo@remotelyyours.com")
demo_user.assign_attributes(
  full_name: "Priya Sharma",
  password: "password123",
  password_confirmation: "password123"
)
demo_user.save!
puts "  Demo user: demo@remotelyyours.com / password123"

# --- Profile ---
profile = demo_user.profile || demo_user.create_profile!
profile.update!(
  headline: "Senior Full-Stack Engineer",
  bio: "Passionate about building scalable web applications. 6+ years of experience with React, Node.js, and Ruby on Rails. Love working in distributed teams and shipping products that users love.",
  location: "Bangalore, India",
  years_of_experience: 6,
  skills: %w[Ruby Rails React TypeScript Node.js PostgreSQL Redis Docker AWS GraphQL],
  preferred_roles: ["Senior Frontend Engineer", "Full-Stack Engineer", "Staff Engineer", "Engineering Lead"],
  desired_role: "Senior Full-Stack Engineer",
  desired_salary_min: 120_000,
  desired_salary_max: 180_000,
  remote_preference: "remote",
  timezone: "Asia/Kolkata",
  available_from: Date.today + 14,
  github_url: "https://github.com/priyasharma",
  linkedin_url: "https://linkedin.com/in/priyasharma",
  portfolio_url: "https://priyasharma.dev",
  onboarding_completed: true,
  talent_brief: "Priya Sharma is a senior-level full-stack engineer with 6 years of deep expertise in React, TypeScript, Ruby on Rails, and cloud infrastructure (AWS, Docker). She excels at building scalable web applications and has a proven track record of shipping production systems in distributed teams. Her ideal next role is a Senior or Staff Full-Stack Engineer position at a remote-first company, with a focus on product engineering and mentorship."
)
puts "  Profile created"

# --- Subscription ---
sub = demo_user.subscription || demo_user.build_subscription
sub.update!(
  plan: "pro",
  status: "active",
  started_at: 15.days.ago,
  expires_at: 15.days.from_now
)
puts "  Pro subscription active"

# --- Jobs ---
JOBS_DATA = [
  {
    external_id: "seed-001", source: "remotive", title: "Senior Frontend Engineer",
    company_name: "Vercel", company_logo_url: "https://logo.clearbit.com/vercel.com",
    location: "Remote (Worldwide)", job_type: "full_time", category: "Software Development",
    description: "<p>We're looking for a Senior Frontend Engineer to join the Vercel team. You'll work on Next.js, our React framework, and help shape the future of web development.</p><h3>What you'll do</h3><ul><li>Build and maintain Next.js features</li><li>Improve developer experience and performance</li><li>Collaborate with the open-source community</li></ul>",
    required_skills: %w[React TypeScript Next.js CSS Node.js],
    salary_min: 150_000, salary_max: 200_000, salary_display: "$150k - $200k",
    apply_url: "https://vercel.com/careers", posted_at: 2.days.ago
  },
  {
    external_id: "seed-002", source: "remotive", title: "Full-Stack Rails Engineer",
    company_name: "Shopify", company_logo_url: "https://logo.clearbit.com/shopify.com",
    location: "Remote (Americas)", job_type: "full_time", category: "Software Development",
    description: "<p>Shopify is looking for a Full-Stack Rails Engineer to help us build the commerce platform that powers millions of merchants. You'll work with Ruby on Rails, React, and GraphQL.</p>",
    required_skills: %w[Ruby Rails React GraphQL PostgreSQL Redis],
    salary_min: 130_000, salary_max: 175_000, salary_display: "$130k - $175k",
    apply_url: "https://shopify.com/careers", posted_at: 1.day.ago
  },
  {
    external_id: "seed-003", source: "remotive", title: "Staff Engineer - Platform",
    company_name: "Stripe", company_logo_url: "https://logo.clearbit.com/stripe.com",
    location: "Remote (US/EU)", job_type: "full_time", category: "Software Development",
    description: "<p>Stripe is hiring a Staff Engineer for our Platform team. You'll design and build the infrastructure that powers financial products for millions of businesses.</p>",
    required_skills: %w[Ruby Go Distributed-Systems AWS Kubernetes PostgreSQL],
    salary_min: 180_000, salary_max: 250_000, salary_display: "$180k - $250k",
    apply_url: "https://stripe.com/jobs", posted_at: 3.days.ago
  },
  {
    external_id: "seed-004", source: "remotive", title: "React Native Developer",
    company_name: "Notion", company_logo_url: "https://logo.clearbit.com/notion.so",
    location: "Remote (US)", job_type: "full_time", category: "Software Development",
    description: "<p>Join Notion's mobile team to build our React Native application. You'll work closely with design and product to deliver a beautiful, fast mobile experience.</p>",
    required_skills: %w[React-Native TypeScript iOS Android Redux],
    salary_min: 140_000, salary_max: 190_000, salary_display: "$140k - $190k",
    apply_url: "https://notion.so/careers", posted_at: 5.days.ago
  },
  {
    external_id: "seed-005", source: "remotive", title: "Backend Engineer (Node.js)",
    company_name: "Linear", company_logo_url: "https://logo.clearbit.com/linear.app",
    location: "Remote (Worldwide)", job_type: "full_time", category: "Software Development",
    description: "<p>Linear is looking for a Backend Engineer to work on our real-time sync engine and API. We use Node.js, TypeScript, and PostgreSQL.</p>",
    required_skills: %w[Node.js TypeScript PostgreSQL Redis WebSockets],
    salary_min: 145_000, salary_max: 195_000, salary_display: "$145k - $195k",
    apply_url: "https://linear.app/careers", posted_at: 4.days.ago
  },
  {
    external_id: "seed-006", source: "adzuna", title: "DevOps / SRE Engineer",
    company_name: "GitLab", company_logo_url: "https://logo.clearbit.com/gitlab.com",
    location: "Remote (Worldwide)", job_type: "full_time", category: "DevOps / Sysadmin",
    description: "<p>GitLab is hiring an SRE to help us scale our platform to millions of developers. You'll work on Kubernetes, Terraform, and monitoring infrastructure.</p>",
    required_skills: %w[Kubernetes Terraform Docker AWS Prometheus Ruby],
    salary_min: 135_000, salary_max: 185_000, salary_display: "$135k - $185k",
    apply_url: "https://about.gitlab.com/jobs", posted_at: 6.days.ago
  },
  {
    external_id: "seed-007", source: "remotive", title: "Product Designer",
    company_name: "Figma", company_logo_url: "https://logo.clearbit.com/figma.com",
    location: "Remote (US)", job_type: "full_time", category: "Design",
    description: "<p>Join Figma's product design team to shape the tools that designers worldwide use every day.</p>",
    required_skills: %w[Figma Prototyping UX-Research Design-Systems],
    salary_min: 130_000, salary_max: 180_000, salary_display: "$130k - $180k",
    apply_url: "https://figma.com/careers", posted_at: 7.days.ago
  },
  {
    external_id: "seed-008", source: "remotive", title: "Engineering Manager",
    company_name: "Supabase", company_logo_url: "https://logo.clearbit.com/supabase.com",
    location: "Remote (Worldwide)", job_type: "full_time", category: "Software Development",
    description: "<p>Supabase is looking for an Engineering Manager to lead our database team. You'll manage a team of 6-8 engineers working on PostgreSQL extensions and real-time features.</p>",
    required_skills: %w[PostgreSQL Leadership Engineering-Management TypeScript Open-Source],
    salary_min: 160_000, salary_max: 220_000, salary_display: "$160k - $220k",
    apply_url: "https://supabase.com/careers", posted_at: 3.days.ago
  },
  {
    external_id: "seed-009", source: "adzuna", title: "Data Engineer",
    company_name: "dbt Labs", company_logo_url: "https://logo.clearbit.com/getdbt.com",
    location: "Remote (US/EU)", job_type: "full_time", category: "Data",
    description: "<p>dbt Labs is hiring a Data Engineer to work on our analytics engineering platform. You'll build data pipelines and optimize query performance.</p>",
    required_skills: %w[Python SQL Snowflake dbt Airflow],
    salary_min: 140_000, salary_max: 185_000, salary_display: "$140k - $185k",
    apply_url: "https://getdbt.com/careers", posted_at: 8.days.ago
  },
  {
    external_id: "seed-010", source: "remotive", title: "Senior TypeScript Engineer",
    company_name: "Prisma", company_logo_url: "https://logo.clearbit.com/prisma.io",
    location: "Remote (EU/Americas)", job_type: "full_time", category: "Software Development",
    description: "<p>Prisma is looking for a Senior TypeScript Engineer to work on our ORM and database tools. You'll contribute to open-source and improve the developer experience.</p>",
    required_skills: %w[TypeScript Node.js PostgreSQL Rust Open-Source],
    salary_min: 135_000, salary_max: 180_000, salary_display: "$135k - $180k",
    apply_url: "https://prisma.io/careers", posted_at: 2.days.ago
  },
  {
    external_id: "seed-011", source: "remotive", title: "Mobile Engineer (iOS)",
    company_name: "Loom", company_logo_url: "https://logo.clearbit.com/loom.com",
    location: "Remote (US)", job_type: "full_time", category: "Software Development",
    description: "<p>Loom is hiring an iOS Engineer to build our mobile video messaging app. You'll work with Swift, UIKit, and AVFoundation.</p>",
    required_skills: %w[Swift iOS UIKit AVFoundation CoreData],
    salary_min: 145_000, salary_max: 195_000, salary_display: "$145k - $195k",
    apply_url: "https://loom.com/careers", posted_at: 5.days.ago
  },
  {
    external_id: "seed-012", source: "remotive", title: "AI/ML Engineer",
    company_name: "Hugging Face", company_logo_url: "https://logo.clearbit.com/huggingface.co",
    location: "Remote (Worldwide)", job_type: "full_time", category: "Software Development",
    description: "<p>Join Hugging Face to work on transformers, model serving, and AI infrastructure. You'll build tools used by millions of ML practitioners.</p>",
    required_skills: %w[Python PyTorch Transformers Docker Kubernetes],
    salary_min: 160_000, salary_max: 230_000, salary_display: "$160k - $230k",
    apply_url: "https://huggingface.co/careers", posted_at: 1.day.ago
  },
].freeze

created_jobs = JOBS_DATA.map do |attrs|
  job = Job.find_or_initialize_by(external_id: attrs[:external_id], source: attrs[:source])
  job.assign_attributes(attrs.merge(is_active: true, is_verified: true))
  job.save!
  job
end
puts "  #{created_jobs.size} jobs seeded"

# --- Job Matches (scored) ---
MATCH_SCORES = {
  "seed-001" => { score: 92, explanation: "Excellent fit. Strong React and TypeScript skills match perfectly. 6 years of experience meets the senior bar. Remote-friendly." },
  "seed-002" => { score: 88, explanation: "Great fit. Deep Rails and React experience. GraphQL knowledge is a bonus. Salary range aligns well." },
  "seed-003" => { score: 78, explanation: "Good fit for systems experience, though Go expertise may need ramping up. Strong distributed systems foundation." },
  "seed-010" => { score: 85, explanation: "Strong TypeScript and Node.js skills. Open-source mindset and PostgreSQL experience are great assets." },
  "seed-005" => { score: 82, explanation: "Solid backend skills with Node.js and PostgreSQL. WebSocket experience would be a growth area." },
  "seed-008" => { score: 72, explanation: "Good leadership potential with 6 years of experience. PostgreSQL knowledge is relevant. Management skills to develop." },
  "seed-004" => { score: 68, explanation: "React skills transfer well to React Native, but limited mobile-specific experience. TypeScript knowledge is a plus." },
  "seed-006" => { score: 60, explanation: "Some Docker and AWS experience, but DevOps/SRE is a career pivot. Ruby knowledge is relevant for GitLab's stack." },
  "seed-012" => { score: 55, explanation: "Python and Docker skills are relevant, but ML/AI specialization would need significant ramp-up." },
  "seed-007" => { score: 35, explanation: "Engineering background provides good product sense, but this is a design role requiring different core skills." },
  "seed-009" => { score: 42, explanation: "Some SQL and Python exposure, but data engineering requires specialized skills not in current profile." },
  "seed-011" => { score: 30, explanation: "Web development skills don't transfer directly to native iOS development with Swift." },
}.freeze

MATCH_SCORES.each do |ext_id, data|
  job = Job.find_by(external_id: ext_id)
  next unless job

  match = JobMatch.find_or_initialize_by(user: demo_user, job: job)
  match.assign_attributes(
    fit_score: data[:score],
    explanation: data[:explanation],
    score_breakdown: {
      skills_match: [data[:score] + rand(-8..8), 100].min.clamp(0, 100),
      experience_match: [data[:score] + rand(-5..10), 100].min.clamp(0, 100),
      role_fit: [data[:score] + rand(-10..5), 100].min.clamp(0, 100),
      location_fit: [data[:score] + rand(0..15), 100].min.clamp(0, 100)
    },
    scored_at: rand(1..24).hours.ago,
    skills_matched: (demo_user.profile.skills & job.required_skills).first(5),
    skills_missing: (job.required_skills - demo_user.profile.skills).first(3)
  )
  match.save!
end
puts "  #{MATCH_SCORES.size} job matches with scores seeded"

puts ""
puts "Seeding complete!"
puts "   Login: demo@remotelyyours.com / password123"
puts ""
