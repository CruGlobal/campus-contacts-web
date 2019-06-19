// Vendors
import React from 'react';
// Project
import { renderWithContext } from '../../../testUtils';
// Subject
import Layout from '../';

describe('<Layout />', () => {
    it('should render properly', async () => {
        renderWithContext(<Layout />).snapshot();
    });
});
