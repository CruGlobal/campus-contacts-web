import { Component, OnInit } from '@angular/core';
import * as angular from 'angular';
import { LoggedInPersonService } from '../../angularjs/services/loggedInPerson.service.js';

@Component({
  selector: 'app-nav',
  templateUrl: './nav.component.html',
  styleUrls: ['./nav.component.scss'],
})
export class NavComponent implements OnInit {
  loggedInPerson: any;
  person = { first_name: '', last_name: '' };

  constructor(loggedInPerson: LoggedInPersonService) {
    this.loggedInPerson = loggedInPerson;
  }

  async ngOnInit() {
    await this.loggedInPerson.loadingPromise;
    this.person = this.loggedInPerson.person;
  }
}

import { downgradeComponent } from '@angular/upgrade/static';

angular.module('missionhubApp').directive('appNav', downgradeComponent({
  component: NavComponent,
}) as angular.IDirectiveFactory);
