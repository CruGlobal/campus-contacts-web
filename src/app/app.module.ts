import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { UpgradeModule } from '@angular/upgrade/static';
import { NavComponent } from './nav/nav.component';
import { loggedInPersonServiceProvider } from '../angularjs/services/loggedInPerson.service';
import { NavSearchDirective } from './upgrade/toAngular';
import { TranslatePipe } from './translate.pipe';

@NgModule({
  declarations: [NavComponent, NavSearchDirective, TranslatePipe],
  imports: [BrowserModule, UpgradeModule],
  providers: [loggedInPersonServiceProvider],
  entryComponents: [NavComponent],
})
export class AppModule {
  constructor(private upgrade: UpgradeModule) {}
  ngDoBootstrap() {
    this.upgrade.bootstrap(document.body, ['missionhubApp'], {
      strictDi: false, // TODO: try to get strictDi working
    });
  }
}
