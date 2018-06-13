import { NgHybridStateDeclaration } from '@uirouter/angular-hybrid';
import { SignInComponent } from './sign-in/sign-in.component';
import { LandingComponent } from './landing/landing.component';

export const routes: NgHybridStateDeclaration[] = [
  {
    name: 'landing',
    abstract: true,
    component: LandingComponent,
  },
  {
    name: 'landing.signIn',
    url: '/sign-in',
    component: SignInComponent,
  },
];
