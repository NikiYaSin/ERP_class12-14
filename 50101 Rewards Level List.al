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
        if (ActivationCodeInFo."Date Activated" <= Today) and (Today <= ActivationCodeInFo."Expiration Date") then
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
        RewardLevelRec: Record "Reward Level";
        MinRewardLevelPoints: Integer;
    begin
        RewardLevelTxt := NoRewardlevelTxt;

        if RewardLevelRec.IsEmpty then
            exit;
        RewardLevelRec.SetRange("Minimum Reward Points", 0, RewardPoints);
        RewardLevelRec.SetCurrentKey("Minimum Reward Points");

        if not RewardLevelRec.FindFirst then
            exit;
        MinRewardLevelPoints := RewardLevelRec."Minimum Reward Points";

        if RewardPoints >= MinRewardLevelPoints then begin
            RewardLevelRec.Reset;
            RewardLevelRec.SetRange("Minimum Reward Points", MinRewardLevelPoints, RewardPoints);
            RewardLevelRec.SetCurrentKey("Minimum Reward Points");
            RewardLevelRec.FindLast;
            RewardLevelTxt := RewardLevelRec.Level;
        end;
    end;

    procedure ActivateCustomerRewards(ActivationCode: Text): Boolean;
    var
        ActivationCodeInfo: Record "Activation Code Information";
    begin
        OnGetActivationCodeStatusFromServer(ActivationCode);
        exit(ActivationCodeInfo.Get(ActivationCode));
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetActivationCodeStatusFromServer(ActivationCode: Text);
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Rewards Ext. Mgt.", 'OnGetActivationCodeStatusFromServer', '', false, false)]
    local procedure OnGetActivationCodeStatusFromServerSubscriber(ActivationCode: Text);
    var
        ActivationCodeInfo: Record "Activation Code Information";
        ResponseText: Text;
        Result: JsonToken;
        JsonRepsonse: JsonToken;
    begin
        if not CanHandle then
            exit;
        if (GetHttpResponse(ActivationCode, ResponseText)) then begin
            JsonRepsonse.ReadFrom(ResponseText);

            if (JsonRepsonse.SelectToken('ActivationResponse', Result)) then begin
                if (Result.AsValue().AsText() = 'Success') then begin
                    if (ActivationCodeInfo.FindFirst()) then
                        ActivationCodeInfo.Delete;

                    ActivationCodeInfo.Init;
                    ActivationCodeInfo.ActivationCode := ActivationCode;
                    ActivationCodeInfo."Date Activated" := Today;
                    ActivationCodeInfo."Expiration Date" := CALCDATE('<1Y>', Today);
                    ActivationCodeInfo.Insert;

                end
            end;
        end;
    end;

    local procedure GetHttpResponse(ActivationCode: Text; var ResponseText: Text): Boolean;
    begin
        if ActivationCode = '' then
            exit(false);

        ResponseText := DummySuccessResponseTxt;
        exit(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnAfterReleaseSalesDoc', '', false, false)]
    local procedure OnAfterReleaseSalesDocSubscriber(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; LinesWereModified: Boolean);
    var
        Customer: Record Customer;
    begin
        if SalesHeader.Status <> SalesHeader.Status::Released then
            exit;

        Customer.Get(SalesHeader."Sell-to Customer No.");
        Customer.RewardPoints += 1;
        Customer.Modify;
    end;

    local procedure CanHandle(): Boolean;
    var
        CustomerRewardsExtMgtSetup: Record "Customer Rewards Mgt. Setup";
    begin
        if CustomerRewardsExtMgtSetup.Get then
            exit(CustomerRewardsExtMgtSetup."Customer Rewards Ext. Mgt. Codeunit ID" = CODEUNIT::"Customer Rewards Ext. Mgt.");
        exit(false);
    end;

}