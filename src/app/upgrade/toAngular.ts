import { Directive, ElementRef, Injector } from '@angular/core';
import { UpgradeComponent } from '@angular/upgrade/static';

@Directive({
  selector: 'nav-search',
})
export class NavSearchDirective extends UpgradeComponent {
  constructor(elementRef: ElementRef, injector: Injector) {
    super('navSearch', elementRef, injector);
  }
}
