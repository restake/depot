export type Message<T = any> = {
  action: number;
  payload: T;
};

export type WebhookData = {
  provider: string;
  project: string;
  version: string;
  time: string;
  note: {
    title: string;
  };
  account: {
    type: string;
    id: string;
    name: string;
  }
};
