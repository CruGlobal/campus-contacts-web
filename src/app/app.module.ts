import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { UpgradeModule } from '@angular/upgrade/static';
import {SurveysModule} from "./surveys/surveys.module";
import {SurveyListComponent} from "./surveys/survey-list.component";

@NgModule({
    imports: [
        BrowserModule,
        UpgradeModule,
        SurveysModule,
    ],
    entryComponents: [
        SurveyListComponent,
    ],
})
export class AppModule {
    constructor(private upgrade: UpgradeModule) { }
    ngDoBootstrap() {
        this.upgrade.bootstrap(document.body, ['missionhubApp'], { strictDi: true });
    }
}
