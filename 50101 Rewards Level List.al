page 50101 "Rewards Level List"
{
    PageType = List;
    ContextSensitiveHelpPage = 'sales-rewards';
    SourceTable = "Reward Level";
    SourceTableView = sorting("Minimum Reward Points") order(ascending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Level; Level)
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the level of reward that the customer has at this point.';
                }

                field("Minimum Reward Points"; "Minimum Reward Points")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the number of points that customers must have to reach this level.';
                }
            }
        }
    }

    trigger OnOpenPage();
    begin

        if (not CustomerRewardsExtMgt.IsCustomerRewardsActivated) then
            Error(NotActivatedTxt);
    end;

    var
        CustomerRewardsExtMgt: Codeunit "Customer Rewards Ext. Mgt.";
        NotActivatedTxt: Label 'Customer Rewards is not activated';
}


codeunit 50101 "Customer Rewards Ext. Mgt."
{
    var
        DummySuccessResponseTxt: Label '{"ActivationResponse": "Success"}', Locked = true;
        NoRewardlevelTxt: Label 'NONE';


    procedure IsCustomerRewardsActivated(): Boolean;
    var
        ActivationCodeInFo: Record "Activation Code Information";
    begin
        if not ActivationCodeInFo.FindFirst then
            exit(false);
        if (ActivationCodeInFo."Date Activated" <= Todaty) and (Today <= ActivationCodeInFo."Expiration Date") then
            exit(true);
        exit(false);
    end;

    procedure OpenCustomerRewardWizard();
    var
        CustomerRewardsWizard: Page "Customer Rewards Wizard";
    begin
        CustomerRewardsWizard.RunModal;
    end;

    procedure OpenRewardsLevelPage();
    var
        RewardsLevelPage: Page "Rewards Level list";
    begin
        RewardsLevelPage.Run;
    end;

    procedure GetRewardLevel(RewardPoints: Integer) RewardLevelTxt: Text;
    var
        RewardLevelQec: Record "Reward Level";
        MinRewardLevelPoints: Integer;
    begin
        RewardLevelTxt := NoRewardlevelTxt;

        if RewardLevelRec.IsEmpty then
            exit;
        RewardLevelRec.SetRange("Minimum Reward Points", 0, RewardPoints);
        RewardLevelRec.SetCurrentKey("Minimum Reward Points");
    end;
}