import React from 'react';

import { renderWithContext } from '../../../testUtils';
import StagesSummary from '../';

describe('<StagesSummary />', () => {
    it('should render properly', async () => {
        renderWithContext(<StagesSummary summary={[]} />).snapshot();
    });

    it('should render properly with summary', async () => {
        const summary = [
            { stage: 'NOT SURE', icon: 'not-sure', count: 14 },
            { stage: 'UNINTERESTED', icon: 'uninterested', count: 12 },
            { stage: 'CURIOUS', icon: 'curious', count: 15 },
            { stage: 'FORGIVEN', icon: 'forgiven', count: 5 },
            { stage: 'GROWING', icon: 'growing', count: 3 },
            { stage: 'GUIDING', icon: 'guiding', count: 0 },
        ];

        renderWithContext(<StagesSummary summary={summary} />).snapshot();
    });
});
