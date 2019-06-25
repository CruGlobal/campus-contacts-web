import { ResponsiveBar } from '@nivo/bar';
import React from 'react';
import { withTheme } from 'emotion-theming';
import { useTranslation } from 'react-i18next';
import i18n from 'i18next';
import { useQuery } from 'react-apollo-hooks';
import gql from 'graphql-tag';
import styled from '@emotion/styled';

const GET_STAGE_REPORT = gql`
    query stages_report {
        stages_report {
            data {
                pathway_stage
                member_count
                steps_added_count
                steps_completed_count
            }
        }
    }
`;

const Wrapper = styled.div`
    height: 400px;
`;

const MemberStagesChart = props => {
    const { data, loading } = useQuery(GET_STAGE_REPORT);
    const { t } = useTranslation('insights');

    if (loading) {
        return <Wrapper>{t('loading')}</Wrapper>;
    }

    const { stages_report: report } = data;

    const MEMBERS_LABEL = i18n.t('insights:members');
    const PERSONAL_STEPS_LABEL = i18n.t('insights:personalSteps');
    const STAGE_LABEL = i18n.t('insights:stage');

    const graphData = report.data.map(row => ({
        [MEMBERS_LABEL]: row.member_count,
        [PERSONAL_STEPS_LABEL]: row.steps_completed_count,
        [STAGE_LABEL]: row.pathway_stage,
    }));

    const { theme } = props;

    return (
        <Wrapper>
            <ResponsiveBar
                data={graphData}
                keys={[MEMBERS_LABEL, PERSONAL_STEPS_LABEL]}
                indexBy={STAGE_LABEL}
                theme={theme.graph}
                margin={{
                    top: 30,
                    right: 0,
                    bottom: 90,
                    left: 30,
                }}
                minValue={'auto'}
                maxValue={'auto'}
                padding={0.4}
                innerPadding={3}
                colors={[theme.colors.highlight, theme.colors.highlightDarker]}
                colorBy="id"
                axisTop={null}
                groupMode={'grouped'}
                axisRight={null}
                axisBottom={{
                    tickSize: 0,
                    tickPadding: 20,
                }}
                axisLeft={{
                    tickSize: 0,
                    tickPadding: 5,
                    tickRotation: 0,
                }}
                legends={[
                    {
                        dataFrom: 'keys',
                        anchor: 'bottom-left',
                        direction: 'row',
                        justify: false,
                        translateX: -24,
                        translateY: 70,
                        itemsSpacing: 2,
                        itemWidth: 90,
                        itemHeight: 20,
                        itemDirection: 'left-to-right',
                        itemOpacity: 0.85,
                        itemTextColor: theme.colors.secondary,
                        symbolSize: 21,
                        symbolShape: 'circle',
                        effects: [
                            {
                                on: 'hover',
                                style: {
                                    itemOpacity: 1,
                                },
                            },
                        ],
                    },
                ]}
                enableGridY={true}
                enableLabel={false}
                animate={true}
                motionStiffness={90}
                motionDamping={15}
            />
        </Wrapper>
    );
};

export default withTheme(MemberStagesChart);
