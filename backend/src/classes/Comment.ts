import { Issue } from './Issue';
import { User } from './User';

export class Comment {
  id!: number;
  issue!: Issue;
  user!: User;
  content!: string;
  created_at!: Date;
}
