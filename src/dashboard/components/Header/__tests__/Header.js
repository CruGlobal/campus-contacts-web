import React from 'react';

import { renderWithContext } from '../../../testUtils';
import Header from '../';

describe('<Header />', () => {
    it('should render properly', async () => {
        renderWithContext(<Header />).snapshot();
    });
});
