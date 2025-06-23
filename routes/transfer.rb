require File.expand_path('../../config/enviroment', __FILE__)

class TransferRoutes < Sinatra::Base
    register AppConfig
    before { authenticate_user! }

    get '/contact_book' do
      erb :transfer_contact_book, layout: :'partial/layout'
    end

    get '/transfer' do
      erb :transfer, layout: :'partial/layout'
    end

    get '/transfer/find_target' do
      erb :prev_transfer, layout: :'partial/layout'
    end

    post '/transfer/find_target' do
      target = BankAccount.find_by(cvu: params[:content_input] ) || BankAccount.find_by(alias: params[:content_input])
      if target
        redirect "/transfer/#{target.id}"
      else
        @error = "Cuenta destino no encontrada"
        erb :prev_transfer, layout: :'partial/layout'
      end
    end

    get '/transfer/:id' do
      @target = params[:id]
      erb :transfer, layout: :'partial/layout'
    end

    post '/transfer' do
      source = current_user.bank_account
      input = params[:amount]
      target = BankAccount.find(params[:destino])
      @error = nil
      if target.nil?
        @error = "Cuenta destino no encontrada"
      elsif source == target
        @error = "No podés transferir a tu propia cuenta."
      end
  
      if @error
        erb :transfer, layout: :'partial/layout'
      else
        transfer = Transaction.new(
          source_account: source,
          target_account: target,
          amount: params[:amount],
          description: params[:description],
          motivo: params[:motivo],
          transaction_date: Time.now,
          transaction_type: 2,
          state: 0
        )
  
        if transfer.save
          Contact.new(user: current_user, contact: target.id).save
          redirect "/transfer/success/#{transfer.id}"
        else
          @error = "No se pudo guardar la transferencia"
          erb :transfer, layout: :'partial/layout'
        end
      end
    end

    get '/transactions/info/:id' do
    @transfer = Transaction.find_by(id: params[:id])
    if @transfer.source_account != current_user.bank_account && @transfer.target_account != current_user.bank_account && !(admin? && session[:admin_active])
      halt 403, "No tenés permiso para ver esta transferencia"
    end
    halt 404, "Transferencia no encontrada" unless @transfer
    if admin? && session[:admin_active]
      erb :transfer_info, layout: :'partial/admins'
    else
    erb :transfer_info, layout: :'partial/layout'
    end

    end
  
    get '/transfer/success/:id' do
      @transfer = Transaction.includes(target_account: :user).find(params[:id])
      halt 404, "Transferencia no encontrada" unless @transfer 
  
      random = SecureRandom.hex(2).upcase
      @transfer_code = "TRF-#{@transfer.id}-#{random}"
      @comprobante_code = "CBT-#{@transfer.id}-#{random}"
      erb :transfer_succes, layout: :'partial/layout'
    end
  
    get '/comprobante/:id' do
      @transfer = Transaction.includes(source_account: :user, target_account: :user).find(params[:id])
  
      random = SecureRandom.hex(2).upcase
      @transfer_code = "TRF-#{@transfer.id}-#{random}"
      @comprobante_code = "CBT-#{@transfer.id}-#{random}"
  
      sender = @transfer.source_account.user
      recipient = @transfer.target_account.user
  
      content_type 'application/pdf'
      pdf = Prawn::Document.new(page_size: 'A4', page_layout: :portrait, margin: 50)
  
      # colores y formato PDF (igual que en tu código original)
      main_color = "0d9b72"
      gray_color = "444444"
      pdf.font "Helvetica"
      pdf.fill_color main_color
      pdf.text "Comprobante de Transferencia", size: 26, style: :bold, align: :center
      pdf.move_down 10
      pdf.stroke_color main_color
      pdf.stroke_horizontal_rule
      pdf.move_down 20
      pdf.fill_color "000000"
      pdf.text "Remitente", size: 14, style: :bold, color: main_color
      pdf.text "#{sender.name} #{sender.last_name}", size: 12
      pdf.move_down 10
      pdf.text "Destinatario", size: 14, style: :bold, color: main_color
      pdf.text "#{recipient.name} #{recipient.last_name}", size: 12
      pdf.move_down 25
      pdf.stroke_horizontal_rule
      pdf.move_down 15
  
      data = [
        ["Código de transferencia:", @transfer_code],
        ["Código de comprobante:", @comprobante_code],
        ["Monto:", "$#{'%.2f' % @transfer.amount}"],
        ["Motivo:", @transfer.motivo || 'Sin motivo especificado'],
        ["Fecha:", @transfer.transaction_date.getlocal.strftime('%d/%m/%Y %H:%M')]
      ]
  
      data.each do |label, value|
        pdf.formatted_text [
          { text: label, styles: [:bold], color: main_color },
          { text: " #{value}", color: gray_color }
        ]
        pdf.move_down 8
      end
  
      pdf.move_down 40
      pdf.stroke_horizontal_rule
      pdf.move_down 5
      pdf.fill_color gray_color
      pdf.text "paystack", size: 9, align: :center, style: :italic
  
      pdf.render
    end
end