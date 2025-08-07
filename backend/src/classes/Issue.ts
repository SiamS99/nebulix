import { User } from './User';
import { Project } from './Project';
import { Sprint } from './Sprint';

export class Issue {
  id!: number;
  title!: string;
  description?: string | null;
  status!: string;
  priority!: string;
  assignee?: User | null;
  project!: Project;
  sprint?: Sprint | null;
  board_column_position?: number | null;
  created_at!: Date;
  updated_at!: Date;
}
