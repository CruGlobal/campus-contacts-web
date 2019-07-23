import React, { useContext, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useQuery } from 'react-apollo-hooks';
import moment from 'moment';
import styled from '@emotion/styled';
import _ from 'lodash';

import Card from '../../components/Card';
import AppContext from '../../appContext';
import Header from '../../components/Header';
import BarChart from '../../components/BarChart';
import StagesSummary from '../../components/StagesSummary';
import RangePicker from '../../components/RangePicker';

import {
    GET_IMPACT_REPORT_MOVED,
    GET_IMPACT_REPORT_STEPS_TAKEN,
    GET_STAGES_REPORT_MEMBER_COUNT,
    GET_STEPS_COMPLETED_REPORT,
    GET_STAGES_REPORT_STEPS_ADDED,
    GET_TOTAL_STEPS_COMPLETED_SUMMARY,
} from './queries';

const PersonalStepsPage = () => {
    const { t } = useTranslation('insights');
    const { orgId } = useContext(AppContext);

    return (
        <div>
            <PersonalStepsTakenInfo orgId={orgId} t={t} />
            <Card title={t('personalSteps.completedTotal')}>
                <PersonalStepsCompletedSummary orgId={orgId} t={t} />
            </Card>
            <Card
                title={t('personalSteps.completed')}
                subtitle={t('personalSteps.completedSubtitle')}
            >
                <PersonalStepsCompletedChart org={orgId} t={t} />
            </Card>
            <Card
                title={t('personalSteps.added')}
                subtitle={t('personalSteps.addedSubtitle')}
            >
                <PersonalStepsAddedChart orgId={orgId} t={t} />
            </Card>
            <PersonalStepsReachedInfo orgId={orgId} t={t} />
            <Card
                title={t('personalSteps.members')}
                subtitle={t('personalSteps.membersSubtitle')}
            >
                <PersonalStepsMemberStagesChart orgId={orgId} t={t} />
            </Card>
        </div>
    );
};

export default PersonalStepsPage;

PersonalStepsPage.propTypes = {};

// Components

const Wrapper = styled.div`
    height: 400px;
    position: relative;
`;

const SummaryWrapper = styled.div`
    display: flex;
    flex-direction: column;
`;

const Footer = styled.div`
    margin-top: 28px;
`;

const LoadingHeader = () => {
    const { t } = useTranslation('insights');
    return <Header>{t('loading')}</Header>;
};

const Loading = () => {
    const { t } = useTranslation('insights');
    return <Wrapper>{t('loading')}</Wrapper>;
};

const ImpactInfo = ({ query, orgId, text }) => {
    const { data, loading } = useQuery(query, {
        variables: {
            organizationId: orgId,
        },
    });
    if (loading) {
        return <LoadingHeader />;
    }
    const { impactReport: report } = data;
    return <Header>{text(report)} </Header>;
};

const PersonalStepsReachedInfo = ({ orgId, t }) => (
    <ImpactInfo
        orgId={orgId}
        query={GET_IMPACT_REPORT_MOVED}
        text={report =>
            t('personalSteps.reached', { count: report.pathwayMovedCount })
        }
    />
);

const PersonalStepsTakenInfo = ({ orgId, t }) => (
    <ImpactInfo
        orgId={orgId}
        query={GET_IMPACT_REPORT_STEPS_TAKEN}
        text={report =>
            t('personalSteps.taken', {
                count: report.stepOwnersCount,
                year: moment().format('YYYY'),
            })
        }
    />
);

const PersonalStepsCompletedChart = ({ orgId, t }) => {
    const [dates, setDates] = useState({});

    const { data, loading } = useQuery(GET_STEPS_COMPLETED_REPORT);

    if (loading) {
        return <Loading />;
    }

    const {
        communityReport: { dayReport: report },
    } = data;

    const graphData = report.map(row => ({
        ['total']: row.personalStepsCompletedCount,
        ['stages']: row.communityStagesReport.map(stage => ({
            name: stage.pathwayStage,
            count: stage.personalStepsCompletedCount,
        })),
        ['date']: row.date.substring(0, 2),
    }));

    const average = Math.floor(_.sumBy(graphData, 'total') / graphData.length);

    return (
        <BarChart
            data={graphData}
            keys={['total']}
            indexBy={'date'}
            average={average}
            tooltipBreakdown={true}
            datesFilter={true}
            onDatesChanged={dates => {
                setDates(dates);
            }}
            legendLabel={t('personalSteps.legend')}
        />
    );
};

const StepsChart = ({ orgId, t, query, mapData, label }) => {
    const { data, loading } = useQuery(query, {
        variables: {
            period: '',
            organizationId: orgId,
            endDate: moment().format(),
        },
    });
    if (loading) {
        return <Loading />;
    }
    const { organizationPathwayStagesReport: report } = data;
    return (
        <Wrapper>
            <BarChart
                data={mapData(report)}
                keys={[label]}
                indexBy={t('stage')}
            />
        </Wrapper>
    );
};

const PersonalStepsMemberStagesChart = ({ orgId, t }) => {
    const MEMBERS_LABEL = t('members');
    return (
        <StepsChart
            orgId={orgId}
            t={t}
            query={GET_STAGES_REPORT_MEMBER_COUNT}
            mapData={report =>
                report.map(row => ({
                    [MEMBERS_LABEL]: row.memberCount,
                    [t('stage')]: row.pathwayStage.name.toUpperCase(),
                }))
            }
            label={MEMBERS_LABEL}
        />
    );
};

const PersonalStepsAddedChart = ({ orgId, t }) => {
    const PERSONAL_STEPS_LABEL = t('personalSteps.label');
    return (
        <StepsChart
            orgId={orgId}
            t={t}
            query={GET_STAGES_REPORT_STEPS_ADDED}
            mapData={report =>
                report.map(row => ({
                    [PERSONAL_STEPS_LABEL]: row.stepsAddedCount,
                    [t('stage')]: row.pathwayStage.name.toUpperCase(),
                }))
            }
            label={PERSONAL_STEPS_LABEL}
        />
    );
};

const PersonalStepsCompletedSummary = ({ orgId, t }) => {
    const [dates, setDates] = useState({
        startDate: moment().subtract(7, 'days'),
        endDate: moment(),
    });

    const { data, loading } = useQuery(GET_TOTAL_STEPS_COMPLETED_SUMMARY);

    if (loading) {
        return <Loading />;
    }

    const onDatesChange = ({ startDate, endDate }) => {
        setDates({ startDate, endDate });
    };

    const {
        communityReport: { communityStagesReport: report },
    } = data;

    const summary = report.map(entry => ({
        stage: entry.pathwayStage,
        icon: entry.pathwayStage.toLowerCase().replace(' ', '-'),
        count: entry.personalStepsCompletedCount,
    }));

    return (
        <SummaryWrapper>
            <StagesSummary summary={summary} />
            <Footer>
                <RangePicker onDatesChange={onDatesChange} />
            </Footer>
        </SummaryWrapper>
    );
};
