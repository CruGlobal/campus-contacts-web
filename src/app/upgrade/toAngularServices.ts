export abstract class UibModal {
  [open: string]: any;
}

export function uibModalServiceFactory(i: any) {
  return i.get('$uibModal');
}

export const uibModalServiceProvider = {
  provide: UibModal,
  useFactory: uibModalServiceFactory,
  deps: ['$injector'],
};
