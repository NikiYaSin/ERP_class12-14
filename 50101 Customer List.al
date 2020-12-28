pageextension 50101 "CustomerList.Ex" extends "Customer List"
{
    actions
    {
        addfirst("&Customer")
        {
            action("Reward Levels")
            {
                ApplicationArea = All;
                Image = CustomerRating;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Open the list of reward levels.';


                trigger OnAction();
                begin
                    if CustomerRewardsExtMgt.IsCustomerRewardsActivated then
                        CustomerRewardsExtMgt.OpenRewardsLevelPage
                    else
                        CustomerRewardsExtMgt.OpenCustomerRewardWizard;
                end;
            }
        }
    }

    var
        CustomerRewardsExtMgt: Codeunit "Customer Rewards Ext. Mgt.";
}