import { Project } from './Project';

export class ProjectBoard {
  id!: number;
  name!: string;
  project!: Project;
  description?: string | null;
  is_default!: boolean;
  created_at!: Date;
}
