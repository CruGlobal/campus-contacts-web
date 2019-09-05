import React from 'react';

import { renderWithContext } from '../../../../testUtils';

import Layout from '..';

describe('<Layout />', () => {
    it('should render properly', async () => {
        renderWithContext(<Layout />, {
            appContext: { orgId: '1' },
        }).snapshot();
    });
});
