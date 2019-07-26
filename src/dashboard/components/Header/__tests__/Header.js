import React from 'react';

import { renderWithContext } from '../../../testUtils';
import Header from '../';

describe('<Header />', () => {
    it('should render properly', async () => {
        renderWithContext(<Header />).snapshot();
    });

    it('should render properly with data', async () => {
        renderWithContext(<Header>Some test header</Header>).snapshot();
    });
});
