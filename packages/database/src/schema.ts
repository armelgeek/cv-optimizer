import {
  pgTable,
  serial,
  varchar,
  text,
  boolean,
  timestamp,
  index,
  foreignKey,
  uuid,
  integer,
  jsonb,
  date,
  pgEnum,
} from "drizzle-orm/pg-core";

export const pages = pgTable("pages", {
  id: serial("id").primaryKey(),
  name: varchar("name", { length: 255 }).notNull(),
});

// Better Auth tables
export const betterAuthUsers = pgTable(
  "user",
  {
    id: text("id").primaryKey(),
    email: text("email").notNull().unique(),
    emailVerified: boolean("emailVerified").notNull().default(false),
    name: text("name"),
    image: text("image"),
    createdAt: timestamp("createdAt").notNull().defaultNow(),
    updatedAt: timestamp("updatedAt").notNull().defaultNow(),
  },
  (table) => [index("user_email_idx").on(table.email)]
);

export const betterAuthSessions = pgTable(
  "session",
  {
    id: text("id").primaryKey(),
    expiresAt: timestamp("expiresAt").notNull(),
    token: text("token").notNull().unique(),
    createdAt: timestamp("createdAt").notNull().defaultNow(),
    updatedAt: timestamp("updatedAt").notNull().defaultNow(),
    ipAddress: text("ipAddress"),
    userAgent: text("userAgent"),
    userId: text("userId").notNull(),
  },
  (table) => [
    foreignKey({ columns: [table.userId], foreignColumns: [betterAuthUsers.id] }),
    index("session_userId_idx").on(table.userId),
  ]
);

export const betterAuthAccounts = pgTable(
  "account",
  {
    id: text("id").primaryKey(),
    accountId: text("accountId").notNull(),
    providerId: text("providerId").notNull(),
    userId: text("userId").notNull(),
    accessToken: text("accessToken"),
    refreshToken: text("refreshToken"),
    idToken: text("idToken"),
    accessTokenExpiresAt: timestamp("accessTokenExpiresAt"),
    refreshTokenExpiresAt: timestamp("refreshTokenExpiresAt"),
    scope: text("scope"),
    password: text("password"),
    createdAt: timestamp("createdAt").notNull().defaultNow(),
    updatedAt: timestamp("updatedAt").notNull().defaultNow(),
  },
  (table) => [
    foreignKey({ columns: [table.userId], foreignColumns: [betterAuthUsers.id] }),
    index("account_userId_idx").on(table.userId),
  ]
);

export const betterAuthOrganizations = pgTable(
  "organization",
  {
    id: text("id").primaryKey(),
    name: text("name").notNull(),
    slug: text("slug").notNull().unique(),
    logo: text("logo"),
    createdAt: timestamp("createdAt").notNull().defaultNow(),
    metadata: text("metadata"),
  },
  (table) => [index("organization_slug_idx").on(table.slug)]
);

export const betterAuthOrganizationMembers = pgTable(
  "organizationMember",
  {
    id: text("id").primaryKey(),
    organizationId: text("organizationId").notNull(),
    userId: text("userId").notNull(),
    role: text("role").notNull().default("member"),
    createdAt: timestamp("createdAt").notNull().defaultNow(),
  },
  (table) => [
    foreignKey({
      columns: [table.organizationId],
      foreignColumns: [betterAuthOrganizations.id],
    }),
    foreignKey({ columns: [table.userId], foreignColumns: [betterAuthUsers.id] }),
    index("organizationMember_organizationId_idx").on(table.organizationId),
    index("organizationMember_userId_idx").on(table.userId),
  ]
);

export const betterAuthVerifications = pgTable(
  "verification",
  {
    id: text("id").primaryKey(),
    identifier: text("identifier").notNull(),
    value: text("value").notNull(),
    expiresAt: timestamp("expiresAt").notNull(),
    createdAt: timestamp("createdAt").defaultNow(),
    updatedAt: timestamp("updatedAt").defaultNow(),
  },
  (table) => [index("verification_identifier_idx").on(table.identifier)]
);

// Account management tables
export const userProfiles = pgTable(
  "user_profiles",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id")
      .notNull()
      .unique()
      .references(() => betterAuthUsers.id),
    bio: text("bio"),
    company: varchar("company", { length: 255 }),
    location: varchar("location", { length: 255 }),
    updatedAt: timestamp("updated_at").notNull().defaultNow(),
  },
  (table) => [index("user_profiles_user_id_idx").on(table.userId)]
);

export const userPreferences = pgTable(
  "user_preferences",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id")
      .notNull()
      .unique()
      .references(() => betterAuthUsers.id),
    emailNotifications: boolean("email_notifications").notNull().default(true),
    marketingEmails: boolean("marketing_emails").notNull().default(false),
    twoFactorEnabled: boolean("two_factor_enabled").notNull().default(false),
    preferredTheme: varchar("preferred_theme", { length: 20 }).notNull().default("system"),
    language: varchar("language", { length: 10 }).notNull().default("en"),
    createdAt: timestamp("created_at").notNull().defaultNow(),
    updatedAt: timestamp("updated_at").notNull().defaultNow(),
  },
  (table) => [index("user_preferences_user_id_idx").on(table.userId)]
);

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CV OPTIMIZER TABLES
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Enums for CV Optimizer
export const jobTypeEnum = pgEnum("job_type", ["CDI", "Stage", "Contract", "Freelance"]);
export const applicationStatusEnum = pgEnum("application_status", ["applied", "interviewing", "rejected", "offer", "archived"]);

// Discovered Jobs from SerpAPI
export const discoveredJobs = pgTable(
  "discovered_jobs",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    google_job_id: varchar("google_job_id", { length: 255 }).notNull().unique(),
    title: varchar("title", { length: 255 }).notNull(),
    company: varchar("company", { length: 255 }).notNull(),
    job_posting_text: text("job_posting_text").notNull(),
    salary_min: integer("salary_min"),
    salary_max: integer("salary_max"),
    job_type: jobTypeEnum("job_type").notNull(),
    location: varchar("location", { length: 255 }).notNull(),
    job_url: text("job_url").notNull(),
    created_at: timestamp("created_at").notNull().defaultNow(),
    expires_at: timestamp("expires_at").notNull(),
  },
  (table) => [
    index("discovered_jobs_google_job_id_idx").on(table.google_job_id),
    index("discovered_jobs_expires_at_idx").on(table.expires_at),
  ]
);

// User Applications (saved optimizations)
export const applications = pgTable(
  "applications",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    user_id: text("user_id")
      .notNull()
      .references(() => betterAuthUsers.id),
    discovered_job_id: uuid("discovered_job_id").references(() => discoveredJobs.id),
    job_title: varchar("job_title", { length: 255 }).notNull(),
    company: varchar("company", { length: 255 }).notNull(),
    job_posting_text: text("job_posting_text").notNull(),
    optimized_cv: text("optimized_cv"),
    cv_match_score: integer("cv_match_score"),
    interview_questions: jsonb("interview_questions"),
    status: applicationStatusEnum("status").notNull().default("applied"),
    created_at: timestamp("created_at").notNull().defaultNow(),
    updated_at: timestamp("updated_at").notNull().defaultNow(),
  },
  (table) => [
    foreignKey({ columns: [table.user_id], foreignColumns: [betterAuthUsers.id] }),
    index("applications_user_id_idx").on(table.user_id),
    index("applications_status_idx").on(table.status),
  ]
);

// CV Analysis results
export const cv_analyses = pgTable(
  "cv_analyses",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    user_id: text("user_id")
      .notNull()
      .references(() => betterAuthUsers.id),
    uploaded_cv: text("uploaded_cv").notNull(),
    feedback: text("feedback").notNull(),
    created_at: timestamp("created_at").notNull().defaultNow(),
  },
  (table) => [
    foreignKey({ columns: [table.user_id], foreignColumns: [betterAuthUsers.id] }),
    index("cv_analyses_user_id_idx").on(table.user_id),
  ]
);

// Mutualised job search cache (by query hash)
export const jobSearchCache = pgTable(
  "job_search_cache",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    query_hash: varchar("query_hash", { length: 255 }).notNull().unique(),
    serpapi_response: jsonb("serpapi_response").notNull(),
    fetched_at: timestamp("fetched_at").notNull().defaultNow(),
    expires_at: timestamp("expires_at").notNull(),
  },
  (table) => [
    index("job_search_cache_query_hash_idx").on(table.query_hash),
    index("job_search_cache_expires_at_idx").on(table.expires_at),
  ]
);

// Add columns to betterAuthUsers for CV Optimizer free tier
// Note: These columns should be added via migration to existing users table
// free_uses_this_month: int DEFAULT 1
// free_uses_reset_date: date nullable
// last_cv_analysis_date: date nullable
// follow_up_emails_this_month: int DEFAULT 0
