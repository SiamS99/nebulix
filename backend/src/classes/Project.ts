import { User } from './User';

export class Project {
  id!: number;
  name!: string;
  owner!: User;
  description?: string | null;
  created_at!: Date;
}
