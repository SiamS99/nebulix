export class User {
  id!: number;
  username!: string;
  email!: string;
  password_hash!: string;
  github_id?: string | null;
  gitlab_id?: string | null;
  role!: string;
  created_at!: Date;
}
