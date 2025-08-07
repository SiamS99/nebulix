import { Project } from './Project';

export class Sprint {
  id!: number;
  name!: string;
  project!: Project;
  start_date!: Date;
  end_date!: Date;
}
