// Vendors
import React from 'react';
import styled from '@emotion/styled';
// Project
import Card from '../../components/Card';
import MemberStagesChart from '../MemberStagesChart';

const Wrapper = styled.div``;

const Index = () => {
    return (
        <Wrapper>
            <Card
                title={'Personal Steps Completed'}
                subtitle={'Total personal steps of faith completed.'}
            />
            <Card
                title={'Member Stages/Current Personal Steps'}
                subtitle={
                    'Total number of members and personal steps of faith selected currently in MissionHub.'
                }
            >
                <MemberStagesChart />
            </Card>
            <Card
                title={'Member Movement'}
                subtitle={
                    'Number of members who changed their stage in the past 6 months.'
                }
            />
        </Wrapper>
    );
};

export default Index;

Index.propTypes = {};
