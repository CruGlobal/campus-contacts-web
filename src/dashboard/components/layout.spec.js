import React from 'react';
import Layout from './layout';

import { renderWithContext } from '../testUtils';

describe('<Layout />', () => {
    it('should render properly', async () => {
        renderWithContext(<Layout orgId={1} />).snapshot();
    });
});
