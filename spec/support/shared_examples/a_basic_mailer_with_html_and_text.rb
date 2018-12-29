#
# Requires a @mail instance variable to be defined, e.g.
#
#   @mail = Marketplace::OrderMailer.purchase_notification(agent_id: @buying_agent.id, order_id: @order.id)
#
# NB shared_contents are the variable names, as Strings, which are then evaluated in the context of the spec.

shared_examples "a basic mailer with html and text" do |shared_contents|
  it 'should not be nil' do
    expect(@mail).not_to be_nil
  end

  describe 'mail content' do
    before :all do
      @html_contents = @mail.body.parts.select{ |part| part.content_type =~ /text\/html/}.first
      @text_contents = @mail.body.parts.select{ |part| part.content_type =~ /text\/plain/}.first
    end

    it 'should be composed of html and text parts' do
      expect(@html_contents).not_to be_nil
      expect(@text_contents).not_to be_nil
    end

    [ :text, :html ].each do |part|
      describe "#{part} part" do
        before :all do
          @contents = self.instance_variable_get("@#{part}_contents")
        end

        shared_contents.each do |var_name|
          it "should include #{var_name}" do
            expect(@contents.body).to include eval(var_name)
          end
        end
      end
    end
  end
end
