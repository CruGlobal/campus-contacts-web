import React from 'react';

import { renderWithContext } from '../../../../testUtils';

import Card from '..';

describe('<Card />', () => {
    it('should render properly', async () => {
        renderWithContext(<Card />).snapshot();
    });

    it('should render properly with children', async () => {
        const child = <div>Children</div>;
        renderWithContext(<Card>{child}</Card>).snapshot();
    });

    it('should render properly with title and subtitle', async () => {
        renderWithContext(
            <Card title={'Title'} subtitle={'Subtitle'} />,
        ).snapshot();
    });
});
