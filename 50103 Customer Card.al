pageextension 50103 "Customer Card Ext." extends "Customer Card"
{
    layout
    {
        addafter(Name)
        {
            field(RewardLevel; RewardLevel)
            {
                ApplicationArea = All;
                Caption = 'Reward Level';
                Description = 'Reward level of the customer.';
                ToolTip = ' Specifies the level of reward that the customer has at this point.';
                Editable = false;
            }
            field(RewardPoints; RewardPoints)
            {
                ApplicationArea = All;
                Caption = 'Reward Points';
                Description = 'Reward Points accrued by customer.';
                ToolTip = ' Specifies the total number of points that the customer has at this point.';
                Editable = false;
            }
        }
    }
    trigger OnAfterGetRecord();
    var
        CustomerRewardsMgtExt: Codeunit "Customer Rewards Ext. Mgt.";
    begin

        RewardLevel := CustomerRewardsMgtExt.GetRewardLevel(RewardPoints);
    end;

    var
        RewardLevel: Text;
}