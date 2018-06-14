import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { UpgradeModule } from '@angular/upgrade/static';
import { UIRouterUpgradeModule } from '@uirouter/angular-hybrid';
import { routes } from './routes';
import { NavComponent } from './nav/nav.component';
import { loggedInPersonServiceProvider } from '../angularjs/services/loggedInPerson.service';
import { NavSearchDirective } from './upgrade/toAngular';
import { TranslatePipe } from './translate.pipe';
import { SignInComponent } from './sign-in/sign-in.component';
import { LandingComponent } from './landing/landing.component';
import { uibModalServiceProvider } from './upgrade/toAngularServices';

@NgModule({
  declarations: [
    NavComponent,
    NavSearchDirective,
    TranslatePipe,
    SignInComponent,
    LandingComponent,
  ],
  imports: [
    BrowserModule,
    UpgradeModule,
    UIRouterUpgradeModule.forRoot({ states: routes }),
  ],
  providers: [loggedInPersonServiceProvider, uibModalServiceProvider],
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
