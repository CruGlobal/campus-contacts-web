import { Component, OnInit } from '@angular/core';
import * as angular from 'angular';
import { LoggedInPersonService } from '../../angularjs/services/loggedInPerson.service';
import { UibModal } from '../upgrade/toAngularServices';

@Component({
  selector: 'app-nav',
  templateUrl: './nav.component.html',
  styleUrls: ['./nav.component.scss'],
})
export class NavComponent implements OnInit {
  person = { id: null, first_name: '', last_name: '', picture: '' };

  constructor(
    private loggedInPerson: LoggedInPersonService,
    private $uibModal: UibModal,
  ) {}

  async ngOnInit() {
    await this.loggedInPerson.loadingPromise;
    this.person = this.loggedInPerson.person;
  }

  openAboutModal() {
    this.$uibModal.open({
      component: 'aboutModal',
      windowClass: 'pivot_theme',
      size: 'md',
    });
  }
}

import { downgradeComponent } from '@angular/upgrade/static';

angular.module('missionhubApp').directive('appNav', downgradeComponent({
  component: NavComponent,
}) as angular.IDirectiveFactory);
