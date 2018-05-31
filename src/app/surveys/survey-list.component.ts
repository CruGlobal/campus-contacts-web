import * as angular from 'angular';
import { Component, Input } from '@angular/core';

@Component({
    selector: 'survey-list',
    templateUrl: './survey-list.component.html',
})
export class SurveyListComponent {
    @Input() surveys: any;
}

import { downgradeComponent } from '@angular/upgrade/static';

angular.module('missionhubApp')
    .directive(
        'surveyList',
        downgradeComponent({ component: SurveyListComponent }) as angular.IDirectiveFactory
    );
