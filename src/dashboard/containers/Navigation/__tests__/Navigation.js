// Vendors
import React from 'react';
import { BrowserRouter as Router } from 'react-router-dom';
// Project
import { renderWithContext } from '../../../testUtils';
// Subject
import Navigation from '../';

describe('<Navigation />', () => {
    it('should render properly', async () => {
        renderWithContext(
            <Router>
                <Navigation />
            </Router>,
            {},
            { orgId: 1 },
        ).snapshot();
    });
});
