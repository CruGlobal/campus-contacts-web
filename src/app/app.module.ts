import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { UpgradeModule } from '@angular/upgrade/static';

@NgModule({
  declarations: [

  ],
  imports: [
    BrowserModule,
    UpgradeModule
  ],
  providers: [],
})
export class AppModule {
  constructor(private upgrade: UpgradeModule) { }
  ngDoBootstrap() {
    this.upgrade.bootstrap(document.body, ['missionhubApp'], { strictDi: false }); // TODO: try to get strictDi working
  }
}
