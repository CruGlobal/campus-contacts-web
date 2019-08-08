import React, { useState } from 'react';
import { useQuery } from 'react-apollo-hooks';
import { useTranslation } from 'react-i18next';

import BarChart from '../BarChart';

const FiltersChart = ({ query, mapData, countAverage, label }) => {
    const [dates, setDates] = useState({});
    const { data, loading } = useQuery(query);
    const { t } = useTranslation('insights');

    if (loading) {
        return <div>{t('loading')}</div>;
    }

    const graphData = mapData(data);
    const average = countAverage(graphData);

    return (
        <BarChart
            data={graphData}
            keys={['total']}
            indexBy={'date'}
            average={average}
            tooltipBreakdown={true}
            datesFilter={true}
            onDatesChanged={dates => setDates(dates)}
            legendLabel={label}
        />
    );
};

export default FiltersChart;
