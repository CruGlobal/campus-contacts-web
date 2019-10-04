import React, { useState } from 'react';
import { useQuery } from 'react-apollo-hooks';
import moment from 'moment';
import _ from 'lodash';

import BarChart from '../BarChart';
import NullState from '../NullState';

interface Props {
    query: any;
    variables?: any;
    mapData: (data: any) => any;
    label: string;
    currentDate?: Date;
    nullContent: string;
}

const FiltersChart = ({
    query,
    variables,
    mapData,
    label,
    currentDate,
    nullContent,
}: Props) => {
    const [index, setIndex] = useState(0);
    const [endDate, setEndDate] = useState(moment(currentDate));
    const [type, setType] = useState('month');

    const { data, loading } = useQuery(query, {
        variables: {
            ...variables,
            period: type === 'month' ? 'P1M' : 'P1Y',
            endDate,
        },
    });

    const checkForNullContent = (data: any) => {
        const nullCheck = data.community.report.daysReport.filter(
            (report: any) => {
                return (
                    report.personalStepsAddedCount !== 0 &&
                    report.othersStepsAddedCount !== 0 &&
                    report.interactionsCount !== 0 &&
                    report.personalStepsCompletedCount !== 0 &&
                    report.othersStepsCompletedCount !== 0
                );
            },
        );

        return nullCheck.length === 0;
    };

    if (loading) {
        return <NullState content={nullContent} />;
    }

    const updateDates = (type: string, index: number) => {
        setType(type);
        setIndex(index);
        setEndDate(
            moment(currentDate).subtract(
                index,
                type === 'month' ? 'months' : 'years',
            ),
        );
    };

    const mapDataDaily = (data: any) => {
        const graphData = [];
        const end = moment(endDate);
        const start = moment(endDate).subtract(1, 'months');

        for (let m = moment(start); m.isBefore(end); m.add(1, 'days')) {
            const exists = _.find(data, { date: m.format('YYYY-MM-DD') });
            graphData.push({
                ...exists,
                date: m.format('DD'),
            });
        }
        return graphData;
    };

    const mapDataMonthly = (data: any) => {
        const graphData = [];
        const end = moment(endDate).endOf('month');
        const start = moment(endDate)
            .subtract(11, 'months')
            .startOf('month');

        for (let m = start; m.isBefore(end); m.add(1, 'months')) {
            const endOfMonth = moment(m).endOf('month');
            const exists = _.filter(data, e =>
                moment(e.date).isBetween(m, endOfMonth),
            );
            const reduced = _.reduce(exists, (result, current) => {
                return {
                    ...result,
                    total: result.total + current.total,
                    stages: [...result.stages, ...current.stages],
                };
            });
            graphData.push({
                ...reduced,
                date: m.format('MM'),
            });
        }
        return graphData;
    };

    const mapDataToType = (data: any) => {
        if (type === 'month') {
            return mapDataDaily(data);
        }
        return mapDataMonthly(data);
    };

    const mappedData = mapData(data);
    const graphData = mapDataToType(mappedData);
    const average = Math.floor(_.sumBy(graphData, 'total') / graphData.length);

    return (
        <BarChart
            nullContent={nullContent}
            nullCheck={checkForNullContent(data)}
            data={graphData}
            keys={['total']}
            indexBy={'date'}
            average={average}
            tooltipBreakdown={true}
            datesFilter={true}
            index={index}
            filterType={type}
            onFilterChanged={(type, index) => updateDates(type, index)}
            legendLabel={label}
        />
    );
};

export default FiltersChart;
