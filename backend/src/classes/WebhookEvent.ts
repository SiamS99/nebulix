import { Project } from './Project';

export class WebhookEvent {
  id!: number;
  source!: string;
  event_type!: string;
  payload!: string;
  received_at!: Date;
  project!: Project;
}
