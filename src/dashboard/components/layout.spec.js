import React from 'react';
import Layout from './layout';

import { renderWithContext } from '../testUtils';
import { ThemeProvider } from 'emotion-theming';

describe('<Layout />', () => {
    it('should render properly', async () => {
        const theme = {
            colors: {
                primary: '#505256',
            },
        };

        renderWithContext(
            <ThemeProvider theme={theme}>
                <Layout orgId={1} />
            </ThemeProvider>,
            { mocks: {} },
        ).snapshot();
    });
});
