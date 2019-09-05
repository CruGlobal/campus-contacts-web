import React from 'react';
import { BrowserRouter as Router } from 'react-router-dom';

import { renderWithContext } from '../../../../testUtils';
import Navigation from '..';

describe('<Navigation />', () => {
    it('should render properly', async () => {
        renderWithContext(
            <Router>
                <Navigation />
            </Router>,
            { appContext: { orgId: 1 } },
        ).snapshot();
    });
});
