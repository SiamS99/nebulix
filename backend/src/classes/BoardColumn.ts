import { ProjectBoard } from './ProjectBoard';

export class BoardColumn {
  id!: number;
  board!: ProjectBoard;
  name!: string;
  status_mapping!: string;
  position_order!: number;
  color?: string | null;
  wip_limit?: number | null;
  created_at!: Date;
}
